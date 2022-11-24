//
//  ValidateArtworksCacheUseCaseTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 12.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ValidateArtworksCacheUseCaseTests: XCTestCase {

	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_validateCache_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()
		store.stubRetrievalWithError(anyError)

		try? sut.validateCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCache])
	}

	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		store.stubRetrievalWith([], dated: .init())

		try? sut.validateCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_doesNotDeleteNonExpiredCache() {
		let artworks = uniqueArtworks().models
		let fixedCurrentDate = Date()
		let nonExpiredTimestamp = fixedCurrentDate.minusArtworksCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		store.stubRetrievalWith(artworks, dated: nonExpiredTimestamp)

		try? sut.validateCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_deletesCacheOnExpiration() {
		let artworks = uniqueArtworks().models
		let fixedCurrentDate = Date()
		let expirationTimestamp = fixedCurrentDate.minusArtworksCacheMaxAge()
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		store.stubRetrievalWith(artworks, dated: expirationTimestamp)

		try? sut.validateCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCache])
	}

	func test_validateCache_deletesExpiredCache() {
		let artworks = uniqueArtworks().models
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.minusArtworksCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		store.stubRetrievalWith(artworks, dated: expiredTimestamp)

		try? sut.validateCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCache])
	}

	func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
		let (sut, store) = makeSUT()
		let deletionError = anyError

		expectOnValidatingCache(sut, toCompleteWith: .failure(deletionError), when: {
			store.stubRetrievalWithError(anyError)
			store.stubDeletionWith(.failure(deletionError))
		})
	}

	func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
		let (sut, store) = makeSUT()

		expectOnValidatingCache(sut, toCompleteWith: .success(()), when: {
			store.stubRetrievalWithError(anyError)
			store.completeDeletionSuccessfully()
		})
	}

	func test_validateCache_succeedsOnEmptyCache() {
		let (sut, store) = makeSUT()

		expectOnValidatingCache(sut, toCompleteWith: .success(()), when: {
			store.stubRetrievalWith([], dated: .init())
		})
	}

	func test_validateCache_succeedsOnNonExpiredCache() {
		let artworks = uniqueArtworks().models
		let fixedCurrentDate = Date()
		let nonExpiredTimestamp = fixedCurrentDate.minusArtworksCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expectOnValidatingCache(sut, toCompleteWith: .success(()), when: {
			store.stubRetrievalWith(artworks, dated: nonExpiredTimestamp)
		})
	}

	func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
		let artworks = uniqueArtworks().models
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.minusArtworksCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		let deletionError = anyError

		expectOnValidatingCache(sut, toCompleteWith: .failure(deletionError), when: {
			store.stubRetrievalWith(artworks, dated: expiredTimestamp)
			store.stubDeletionWith(.failure(deletionError))
		})
	}

	func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
		let artworks = uniqueArtworks().models
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.minusArtworksCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expectOnValidatingCache(sut, toCompleteWith: .success(()), when: {
			store.stubRetrievalWith(artworks, dated: expiredTimestamp)
			store.completeDeletionSuccessfully()
		})
	}

	// MARK: - Helpers

	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalArtworksLoader, store: ArtworksStoreSpy) {
		let store = ArtworksStoreSpy()
		let sut = LocalArtworksLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expectOnValidatingCache(
		_ sut: LocalArtworksLoader,
		toCompleteWith expectedResult: Result<Void, Error>,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		action()

		let receivedResult = Result { try sut.validateCache() }

		switch (receivedResult, expectedResult) {
		case (.success, .success):
			break

		case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
			XCTAssertEqual(receivedError, expectedError, file: file, line: line)

		default:
			XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
		}
	}
}
