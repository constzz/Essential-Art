//
//  LoadArtworksFromCacheUseCaseTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class LoadArtworksFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyError
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.stubRetrievalWithError(retrievalError)
        })
    }
    
    func test_load_deliversNoArtworksOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.stubRetrievalWith([], dated: .init())
        })
    }
    
    func test_load_deliversCachedArtworksOnNonExpiredCache() {
        let artworks = uniqueArtworks().models
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.adding(days: -14).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(artworks), when: {
            store.stubRetrievalWith(artworks, dated: nonExpiredTimestamp)
        })
    }

    
    func test_load_deliversNoArtworksOnCacheExpiration() {
        let artworks = uniqueArtworks().models
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.adding(days: -14)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.stubRetrievalWith(artworks, dated: expirationTimestamp)
        })
    }
    
    func test_load_deliversNoArtworksOnExpiredCache() {
        let artworks = uniqueArtworks().models
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.adding(days: -14).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.stubRetrievalWith(artworks, dated: expiredTimestamp)

        })
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        store.stubRetrievalWithError(anyError)
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        store.stubRetrievalWith([], dated: Date())
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let artworks = uniqueArtworks()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.adding(days: -14).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.stubRetrievalWith(artworks.models, dated: nonExpiredTimestamp)
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let artworks = uniqueArtworks()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.adding(days: -14)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.stubRetrievalWith(artworks.models, dated: expirationTimestamp)
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let artworks = uniqueArtworks()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.adding(days: -14).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.stubRetrievalWith(artworks.models, dated: expiredTimestamp)
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
    
    private func expect(
        _ sut: LocalArtworksLoader,
        toCompleteWith expectedResult: Result<[Artwork], Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        
        let receivedResult = Result(catching: { try sut.load() })
        
        switch (receivedResult, expectedResult) {
        case let (.success(artworks), .success(expectedArtworks)):
            XCTAssertEqual(artworks, expectedArtworks, file: file, line: line)
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
}
