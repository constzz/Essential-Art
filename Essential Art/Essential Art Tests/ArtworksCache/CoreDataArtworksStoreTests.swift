//
//  CoreDataArtworksStoreTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 12.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class CoreDataArtworksStoreTests: XCTestCase {
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieve: .success(.none))
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieveTwice: .success(.none))
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = makeSUT()
		let artworks = uniqueArtworks().models
		let timestamp = Date()
		try sut.insert(artworks, timestamp: timestamp)

		expect(sut, toRetrieve: .success(.some((artworks, timestamp))))
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = makeSUT()
		let artworks = uniqueArtworks().models
		let timestamp = Date()
		try sut.insert(artworks, timestamp: timestamp)

		expect(sut, toRetrieveTwice: .success(.some((artworks, timestamp))))
	}

	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = makeSUT()
		let artworks = uniqueArtworks().models
		let timestamp = Date()
		try sut.insert(artworks, timestamp: timestamp)

		expect(sut, toRetrieve: .success((artworks, timestamp)))
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = makeSUT()
		for _ in 1 ... 2 {
			let artworks = uniqueArtworks().models
			let timestamp = Date()
			try sut.insert(artworks, timestamp: timestamp)
		}
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = makeSUT()
		try sut.insert(uniqueArtworks().models, timestamp: Date())

		let artworks = uniqueArtworks().models
		let timestamp = Date()
		try sut.insert(artworks, timestamp: timestamp)
		expect(sut, toRetrieve: .success((artworks, timestamp)))
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		XCTAssertNoThrow(try sut.deleteCachedArtworks())
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()

		try sut.deleteCachedArtworks()
		expect(sut, toRetrieve: .success(.none))
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = makeSUT()
		let (artworks, timestamp) = (uniqueArtworks().models, Date())

		try sut.insert(artworks, timestamp: timestamp)
		XCTAssertNoThrow(try sut.deleteCachedArtworks())
	}

	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = makeSUT()

		try sut.insert(uniqueArtworks().models, timestamp: Date())
		try sut.deleteCachedArtworks()

		expect(sut, toRetrieve: .success(.none))
	}

	private func makeSUT() -> ArtworksStore {
		let storeURL = URL(fileURLWithPath: "/dev/null") // path to temporary directory
		let sut = try! CoreDataArtworksStore(storeURL: storeURL)
		trackForMemoryLeaks(sut)
		return sut
	}

	private func expect(
		_ sut: ArtworksStore,
		toRetrieve expectedResult: Swift.Result<ArtworksCached?, Error>,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let retrievedResult = Result { try sut.retrieve() }

		switch (expectedResult, retrievedResult) {
		case (.success(.none), .success(.none)),
		     (.failure, .failure):
			break

		case let (.success(.some(expected)), .success(.some(retrieved))):
			XCTAssertEqual(retrieved.artworks, expected.artworks, file: file, line: line)
			XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)

		default:
			XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
		}
	}

	private func expect(
		_ sut: ArtworksStore,
		toRetrieveTwice expectedResult: Swift.Result<ArtworksCached?, Error>,
		file: StaticString = #file,
		line: UInt = #line
	) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
}
