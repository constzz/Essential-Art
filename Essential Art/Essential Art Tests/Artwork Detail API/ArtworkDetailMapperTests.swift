//
//  ArtworkDetailMapperTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ArtworkDetailMapperTests: XCTestCase {

	func test_map_throwsErrorOnNon200ResponseStatusCode() throws {
		let artworksJSON = makeArtworkDetailJSON([:], baseURL: anyURL)
		let non200StatusCodes = [199, 201, 203, 299, 301, 400]
		try non200StatusCodes.forEach { statusCode in
			XCTAssertThrowsError(
				try ArtworkDetailMapper.map(data: artworksJSON, response: HTTPURLResponse(statusCode: statusCode)),
				"Expected to throw on \(statusCode) status code."
			)
		}
	}

	func test_map_throwsErrorOnInvalidData() throws {
		let invalidData = Data("invalid data".utf8)

		let non200StatusCodes = [199, 200, 201, 299, 301, 400, 502]
		try non200StatusCodes.forEach { statusCode in
			XCTAssertThrowsError(
				try ArtworkDetailMapper.map(data: invalidData, response: HTTPURLResponse(statusCode: statusCode))
			)
		}
	}

	func test_map_throwsError_on200ResponseStatusCodeAndEmptyJSONlist() throws {
		let emptyJSON = makeArtworkDetailJSON([:], baseURL: anyURL)

		XCTAssertThrowsError(
			try ArtworkDetailMapper.map(data: emptyJSON, response: HTTPURLResponse(statusCode: 200))
		)
	}

	func test_map_deliversArtworkDetails_on200ResponseStatusCodeAndItemsJSON() throws {
		let baseURL = anyURL

		let artwork1 = makeArtwork(
			imageID: "1234",
			title: "Any title",
			baseURL: baseURL,
			description: "Description",
			urlSuffix: "full/843,/0/default.jpg",
			artist: "A famous one")

		let artwork2 = makeArtwork(
			imageID: "5678",
			title: "The art of programming",
			baseURL: baseURL,
			description: nil,
			urlSuffix: "full/843,/0/default.jpg",
			artist: "Unknown artist")

		for artwork in [artwork1, artwork2] {
			let json = makeArtworkDetailJSON(artwork.json, baseURL: baseURL)

			let mappedItem = try ArtworkDetailMapper.map(data: json, response: HTTPURLResponse(statusCode: 200))

			XCTAssertEqual(artwork.model, mappedItem)
		}
	}

	private func makeArtwork(
		imageID: String,
		title: String,
		baseURL: URL,
		description: String?,
		urlSuffix: String,
		artist: String
	) -> (model: ArtworkDetail, json: [String: Any]) {

		let json = [
			"image_id": imageID,
			"artist_display": artist,
			"title": title,
			"thumbnail": [
				"alt_text": description
			]
		].compactMapValues({ $0 })

		let artwork = ArtworkDetail(
			title: title,
			artist: artist,
			description: description,
			imageURL: baseURL.appendingPathComponent(imageID).appendingPathComponent(urlSuffix))

		return (artwork, json)
	}

	private func makeArtworkDetailJSON(
		_ artwork: [String: Any],
		baseURL: URL
	) -> Data {
		let json: [String: Any] = [
			"data": artwork,
			"config": [
				"iiif_url": baseURL.absoluteString
			]
		]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}
