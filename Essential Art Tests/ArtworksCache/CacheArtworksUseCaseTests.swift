//
//  CacheArtworksUseCaseTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 10.11.2022.
//

import Foundation
import XCTest
import Essential_Art

public struct LocalArtwork: Equatable {
    public let title: String
    public let imageURL: URL
    public let artist: String
    
    public init(
        title: String,
        imageURL: URL,
        artist: String
    ) {
        self.title = title
        self.imageURL = imageURL
        self.artist = artist
        
    }
}

protocol ArtworksStore {
    func insert(_ artworks: [Artwork], timestamp: Date) throws
    func deleteCachedArtworks() throws
    func retrieve() throws -> [Artwork]
}

class ArtworksStoreSpy: ArtworksStore {
    enum Message: Equatable {
        case deleteCache
        case retrieve
        case insert([Artwork], Date)
    }
    var receivedMessages = [Message]()
    
    func insert(_ artworks: [Artwork], timestamp: Date) throws {
        receivedMessages.append(.insert(artworks, timestamp))
    }
    
    func retrieve() throws -> [Artwork] {
        receivedMessages.append(.retrieve)
        return stubbedArtworks
    }
    
    func deleteCachedArtworks() throws {
        receivedMessages.append(.deleteCache)
        try deletionResult?.get()
    }
    
    // MARK: Stubbing helpers
    var stubbedArtworks: [Artwork] = []
    
    typealias DeletionResult = Swift.Result<Void, Error>
    private var deletionResult: DeletionResult?
    func stubDeletionWith(_ deletionResult: DeletionResult) {
        self.deletionResult = deletionResult
    }
}

class LocalArtworksLoader {
    private let store: ArtworksStoreSpy
    private let currentDate:  () -> Date
    
    init(store: ArtworksStoreSpy, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ artworks: [Artwork]) throws {
        try store.deleteCachedArtworks()
        try store.insert(artworks, timestamp: currentDate())
    }
}

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
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.stubDeletionWith(.failure(deletionError))
        })
    }
    
    // MARK: - Helpers
    private var anyError = NSError(domain: "any-error", code: 0)
    
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
    
    func uniqueArtwork() -> Artwork {
        return Artwork(title: "any", imageURL: anyURL, artist: "any")
    }
    
    private func uniqueArtworks() -> (models: [Artwork], localItems: [LocalArtwork]) {
        let models = [uniqueArtwork(), uniqueArtwork()]
        return (models, models.map { LocalArtwork(title: $0.title, imageURL: $0.imageURL, artist: $0.artist) })
    }
    
    private func expect(
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
