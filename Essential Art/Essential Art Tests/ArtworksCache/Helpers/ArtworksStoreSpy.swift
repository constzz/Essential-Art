//
//  ArtworksStoreSpy.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation
import Essential_Art

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
    
    func retrieve() throws -> ArtworksCached? {
        receivedMessages.append(.retrieve)
        return try retrieveResult?.get()
    }
    
    func deleteCachedArtworks() throws {
        receivedMessages.append(.deleteCache)
        try deletionResult?.get()
    }
    
    // MARK: Stubbing helpers
    typealias RetrieveResult = Swift.Result<ArtworksCached, Error>
    private var retrieveResult: RetrieveResult?
    func stubRetrievalWith(_ artworks: [Artwork], dated timestamp: Date) {
        self.retrieveResult = .success((artworks, timestamp))
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
