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

class ArtworksStoreSpy {
    var receivedMessages = [String]()
}

class LocalArtworksLoader {
    private let store: ArtworksStoreSpy
    private let currentDate:  () -> Date
    
    init(store: ArtworksStoreSpy, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ artworks: [Artwork]) throws {
        
    }
}

class CacheArtworksUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
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
