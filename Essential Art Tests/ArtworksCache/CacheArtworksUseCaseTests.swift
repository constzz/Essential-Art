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
    /// Date when when LocalArtwork was added to the local storage
    public let timestamp: Date
    
    public init(
        title: String,
        imageURL: URL,
        artist: String,
        timestamp: Date
    ) {
        self.title = title
        self.imageURL = imageURL
        self.artist = artist
        self.timestamp = timestamp
    }
}

protocol ArtworksStore {
    func insert(_ artworks: [Artwork], timestamp: Date) throws
    func deleteCachedArtworks() throws
    func retrieve() throws -> [LocalArtwork]?
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
        try stubbedInsertionResult?.get()
    }
    
    func retrieve() throws -> [LocalArtwork]? {
        receivedMessages.append(.retrieve)
        return try retrieveResult?.get()
    }
    
    func deleteCachedArtworks() throws {
        receivedMessages.append(.deleteCache)
        try deletionResult?.get()
    }
    
    // MARK: Stubbing helpers
    typealias RetrieveResult = Swift.Result<[LocalArtwork], Error>
    private var retrieveResult: RetrieveResult?
    func stubRetrievalWith(_ artworks: [Artwork], dated timestamp: Date) {
        let localArtworks = artworks.map {
            LocalArtwork(title: $0.title, imageURL: $0.imageURL, artist: $0.artist, timestamp: timestamp)
        }
        self.retrieveResult = .success(localArtworks)
    }
    
    func stubRetrievalWithError(_ error: Swift.Error) {
        retrieveResult = .failure(error)
    }
    
    typealias InsertionResult = Swift.Result<Void, Error>
    private var stubbedInsertionResult: InsertionResult?
    func stubInsertionWith(_ insertionResult: InsertionResult) {
        stubbedInsertionResult = insertionResult
    }
    
    var stubbedArtworks: [Artwork] = []
    
    
    typealias DeletionResult = Swift.Result<Void, Error>
    private var deletionResult: DeletionResult?
    func stubDeletionWith(_ deletionResult: DeletionResult) {
        self.deletionResult = deletionResult
    }
    func completeDeletionSuccessfully() {
        stubDeletionWith(.success(()))
        try! deleteCachedArtworks()
    }
}

class LocalArtworksLoader {
    private let store: ArtworksStoreSpy
    private let currentDate:  () -> Date
    
    init(store: ArtworksStoreSpy, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func load() throws -> [Artwork] {
        return try store.retrieve()
    }
    
    func save(_ artworks: [Artwork]) throws {
        try store.deleteCachedArtworks()
        try store.insert(artworks, timestamp: currentDate())
    }
}

private extension LocalArtwork {
    var model: Artwork {
        return Artwork(title: title, imageURL: imageURL, artist: artist)
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
