//
//  ArtworkMapperTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ArtworkMapperTests: XCTestCase {

	func test_map_throwsErrorOnNon200ResponseStatusCode() throws {
		let artworksJSON = makeArtworksJSON([], baseURL: anyURL)
		let non200StatusCodes = [199, 201, 203, 299, 301, 400]
		try non200StatusCodes.forEach { statusCode in
			XCTAssertThrowsError(
				try ArtworkMapper.map(data: artworksJSON, response: HTTPURLResponse(statusCode: statusCode)),
				"Expected to throw on \(statusCode) status code."
			)
		}
	}

	func test_map_throwsErrorOnInvalidData() throws {
		let invalidData = Data("invalid data".utf8)

		let non200StatusCodes = [199, 200, 201, 299, 301, 400, 502]
		try non200StatusCodes.forEach { statusCode in
			XCTAssertThrowsError(
				try ArtworkMapper.map(data: invalidData, response: HTTPURLResponse(statusCode: statusCode))
			)
		}
	}

	func test_map_deliversEmptyList_on200ResponseStatusCodeAndEmptyJSONlist() throws {
		let emptyJSON = makeArtworksJSON([], baseURL: anyURL)

		let (mappedItems, _) = try ArtworkMapper.map(data: emptyJSON, response: HTTPURLResponse(statusCode: 200))

		XCTAssertEqual(mappedItems, [])
	}

	func test_map_deliversItems_on200ResponseStatusCodeAndItemsJSON() throws {
		let baseURL = anyURL
		let artwork1 = makeArtwork(
			imageID: "1234",
			title: "Any title",
			baseURL: baseURL,
			urlSuffix: "full/843,/0/default.jpg",
			artist: "A famous one")

		let artwork2 = makeArtwork(
			imageID: "5678",
			title: "The art of programming",
			baseURL: baseURL,
			urlSuffix: "full/843,/0/default.jpg",
			artist: "Unknown artist")

		let json = makeArtworksJSON([artwork1.json, artwork2.json], baseURL: baseURL)

		let (mappedItems, _) = try ArtworkMapper.map(data: json, response: HTTPURLResponse(statusCode: 200))

		XCTAssertEqual([artwork1.model, artwork2.model], mappedItems)
	}

	func test_map_deliversHasNextBool_on200ResponseStatusCodeAccordingToPagination() throws {

		for hasNext in [true, false] {
			let pagination: Pagination = (currentPage: hasNext ? 1 : 2, totalPages: 3)
			let emptyJSON = makeArtworksJSON([], baseURL: anyURL, pagination: pagination)

			let (_, mappedHasNext) = try ArtworkMapper.map(data: emptyJSON, response: HTTPURLResponse(statusCode: 200))

			XCTAssertEqual(hasNext, mappedHasNext)
		}
	}

	// MARK: - Helpers
	private typealias Pagination = (currentPage: Int, totalPages: Int)

	private func makeArtwork(
		imageID: String,
		title: String,
		baseURL: URL,
		urlSuffix: String,
		artist: String
	) -> (model: Artwork, json: [String: Any]) {
		let id = UUID().hashValue

		let json = [
			"image_id": imageID,
			"artist_display": artist,
			"title": title,
			"id": id
		].compactMapValues({ $0 })

		let artwork = Artwork(
			title: title,
			imageURL: baseURL.appendingPathComponent(imageID).appendingPathComponent(urlSuffix),
			artist: artist,
			id: id)

		return (artwork, json)
	}

	private func makeArtworksJSON(
		_ artworks: [[String: Any]],
		baseURL: URL,
		pagination: Pagination = (0, 1)
	) -> Data {
		let json: [String: Any] = [
			"data": artworks,
			"config": [
				"iiif_url": baseURL.absoluteString
			],
			"pagination": [
				"current_page": pagination.currentPage,
				"total_pages": pagination.totalPages
			]
		]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}

extension HTTPURLResponse {
	convenience init(statusCode: Int) {
		self.init(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
	}
}
