//
//  Essential_Art_API_EndToEnd_Tests.swift
//  Essential Art API EndToEnd Tests
//
//  Created by Konstantin Bezzemelnyi on 09.11.2022.
//

import XCTest
import Essential_Art

class Essential_Art_API_EndToEnd_Tests: XCTestCase {

	func test_endToEndTestServerGETArtworksList_matchesTheNumberOfArtworksInQuery() {
		let artworksLimit = 5

		switch getArtworks(limit: artworksLimit) {
		case .success(let artworks):
			XCTAssertEqual(artworks.count, artworksLimit)
			for index in 0 ... 4 {
				XCTAssertEqual(artworks[index].title, expectedArtworks[index].title)

				// TODO: adjust check. Not equals (if remove replacingOccurrences). Because of the response with not \n and differenet -, – (en dash and em dash)
				XCTAssertEqual(
					artworks[index].artist
						.replacingOccurrences(of: "\n", with: " ")
						.replacingOccurrences(of: "–", with: " ")
						.replacingOccurrences(of: "-", with: " "),
					expectedArtworks[index].artist
				)

				XCTAssertEqual(artworks[index].imageURL, expectedArtworks[index].imageURL)
			}

		case .failure(let error):
			XCTFail("Expected success, but recieved \(error) instead.")
		}
	}

	func test_endToEndTestServerGETArtworkImageData_returnsNonEmptyData() {
		switch getArtowkImageData() {
		case .success(let data):
			XCTAssert(!data.isEmpty, "Expected artwork image data to be not empty.")

		case .failure(let error):
			XCTFail("Expected success result, but recieved \(error) instead")
		}
	}

	private let expectedArtist = "Vincent van Gogh Dutch, 1853 1890"
	private lazy var expectedArtworks = [
		Artwork(title: "The Bedroom", imageURL: imageURLForID("25c31d8d-21a4-9ea1-1d73-6a2eca4dda7e"), artist: expectedArtist),
		Artwork(title: "Self-Portrait", imageURL: imageURLForID("26d3cea8-44c0-bfbd-a91a-19a007517152"), artist: expectedArtist),
		Artwork(title: "The Poet\'s Garden", imageURL: imageURLForID("9ea77636-76e9-9031-6b92-ff34512d7cbc"), artist: expectedArtist),
		Artwork(title: "A Peasant Woman Digging in Front of Her Cottage", imageURL: imageURLForID("1d3a275d-45dd-6026-b6ed-d7d8df417a3d"), artist: expectedArtist),
		Artwork(title: "The Drinkers", imageURL: imageURLForID("d0ff5b36-bb38-b156-6042-5c8545352c2f"), artist: expectedArtist),
	]

	private func imageURLForID(_ id: String) -> URL {
		return URL(string: "https://www.artic.edu/iiif/2/" + id + "/full/400,/0/default.jpg")!
	}

	private var baseURL = URL(string: "https://api.artic.edu")!

	private func getArtworks(limit: Int) -> Swift.Result<[Artwork], Error> {
		let url = ArticEndpoint.get(page: 0, limit: limit).url(baseURL: baseURL)
			.appendingPathComponent("/search")
			.appending([
				URLQueryItem(name: "limit", value: String(limit)),
				URLQueryItem(name: "q", value: "Gogh"),
				URLQueryItem(name: "fields", value: "id,title,artist_display,image_id"),
			])!

		return request(fromURL: url, mappingWith: { try ArtworkMapper.map(data: $0, response: $1).artworks })
	}

	func getArtowkImageData() -> Swift.Result<Data, Error> {
		let url = imageURLForID("25c31d8d-21a4-9ea1-1d73-6a2eca4dda7e")

		return request(fromURL: url, mappingWith: { try ArticImageDataMapper.map($0, from: $1).data })
	}

	private func request<T>(fromURL url: URL, mappingWith mapper: @escaping (Data, HTTPURLResponse) throws -> T) -> Swift.Result<T, Error> {
		let configuration = URLSessionConfiguration.ephemeral
		let session = URLSession(configuration: configuration)

		let exp = expectation(description: "Wait for completion")
		var result: Swift.Result<T, Error>!

		URLSessionHTTPClient(session: session).get(from: url) { recievedResult in
			result = .init(catching: {
				let (data, response) = (try recievedResult.get().0, try recievedResult.get().1)
				return try mapper(data, response)
			})
			exp.fulfill()
		}

		wait(for: [exp], timeout: 5.0)

		return result
	}
}

private extension Artwork {
	init(title: String, imageURL: URL, artist: String) {
		self.init(title: title, imageURL: imageURL, artist: artist, id: UUID().hashValue)
	}
}

private extension URL {
	/// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
	/// URL must conform to RFC 3986.
	func appending(_ queryItems: [URLQueryItem]) -> URL? {
		guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
			// URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
			return nil
		}

		urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

		return urlComponents.url
	}
}
