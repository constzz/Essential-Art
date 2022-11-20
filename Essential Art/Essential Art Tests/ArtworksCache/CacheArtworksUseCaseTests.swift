//
//  CacheArtworksUseCaseTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 10.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class CacheArtworksUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    /// Deletion happens to clear the previous cached items
    func test_save_doesNotCacheOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError
        store.stubDeletionWith(.failure(deletionError))
        
        try? sut.save(uniqueArtworks().models)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let timestampStubbed = Date()
        let (sut, store) = makeSUT(currentDate: { timestampStubbed })
        let artworks = uniqueArtworks().models
        try? sut.save(artworks)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache, .insert(artworks, timestampStubbed)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError
        
        expectOnSave(sut, toCompleteWithError: deletionError, when: {
            store.stubDeletionWith(.failure(deletionError))
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyError
        
        expectOnSave(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.stubInsertionWith(.failure(insertionError))
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expectOnSave(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            
            store.stubInsertionWith(.success(()))
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
    
    private func expectOnSave(
        _ sut: LocalArtworksLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        
        do {
            try sut.save(uniqueArtworks().models)
        } catch {
            XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
        }
    }
}
