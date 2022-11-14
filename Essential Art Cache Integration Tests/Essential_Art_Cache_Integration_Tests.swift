//
//  Essential_Art_Cache_Integration_Tests.swift
//  Essential Art Cache Integration Tests
//
//  Created by Konstantin Bezzemelnyi on 14.11.2022.
//

import XCTest
import Essential_Art

class Essential_Art_Cache_Integration_Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }
    
    func test_loadArtworks_deliversNoItemsOnEmptyCache() {
        let artworksLoader = makeSUT()
        
        expect(artworksLoader, toLoad: [])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> LocalArtworksLoader {
        let store: ArtworksStore = try! CoreDataArtworksStore(storeURL: testSpecificStoreURL)
        let loader = LocalArtworksLoader(store: store, currentDate: Date.init)
        
        return loader
    }
    
    
    private func expect(_ sut: LocalArtworksLoader, toLoad expectedArtworks: [Artwork], file: StaticString = #file, line: UInt = #line) {
        let result = Swift.Result { try sut.load() }
        switch result {
        case .success(let artworks):
            XCTAssertEqual(artworks, expectedArtworks, file: file, line: line)
        case .failure(let error):
            XCTFail("Expected to load artworks, but recieved \(error) instead.")
        }
    }
    
    private var testSpecificStoreURL: URL {
        return cacheDirectory.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var cacheDirectory: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}