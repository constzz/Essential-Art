//
//  Essential_Art_Cache_Integration_Tests.swift
//  Essential Art Cache Integration Tests
//
//  Created by Konstantin Bezzemelnyi on 14.11.2022.
//

import XCTest
import Essential_Art

class Essential_Art_Cache_Integration_Tests: XCTestCase, ArtworksCacheIntegrationTests {
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
    
    func test_loadArtworks_deliversItemsSavedOnASeparateInstance() {
        let artworksLoaderToPerformSave = makeSUT()
        let artworksLoaderToPerformLoad = makeSUT()
        let artworks = uniqueArtworks().models
        
        save(artworks, with: artworksLoaderToPerformSave)
        
        expect(artworksLoaderToPerformLoad, toLoad: artworks)
    }
    
    func test_saveArtworks_overridesItemsSavedOnASeparateInstance() {
        let artworksLoaderToPerformFirtsSave = makeSUT()
        let artworksLoaderToPerformLastSave = makeSUT()
        let artworksLoaderToPerformLoad = makeSUT()
        let artworks = uniqueArtworks().models
        
        save(uniqueArtworks().models, with: artworksLoaderToPerformFirtsSave)
        save(artworks, with: artworksLoaderToPerformLastSave)
        
        expect(artworksLoaderToPerformLoad, toLoad: artworks)
    }
    
    func test_validateArtworksCache_doesNotDeleteRecentlySavedArtworks() {
        let artworksLoaderToPerformSave = makeSUT()
        let artworksLoaderToPerformValidation = makeSUT()
        let artworks = uniqueArtworks().models
        
        save(artworks, with: artworksLoaderToPerformSave)
        validateCache(artworksLoaderToPerformValidation)
        
        expect(artworksLoaderToPerformSave, toLoad: artworks)
    }
    
    func test_validateArtworksCache_deletesArtworksSavedInADistantPast() {
        let artworksLoaderToPerformSave = makeSUT(currentDate: .distantPast)
        let artworksLoaderToPerformValidation = makeSUT(currentDate: .init())
        let artworks = uniqueArtworks().models
        
        save(artworks, with: artworksLoaderToPerformSave)
        validateCache(artworksLoaderToPerformValidation)
        
        expect(artworksLoaderToPerformSave, toLoad: [])
    }

    
    // MARK: - Helpers
    private func makeSUT(currentDate: Date = .init()) -> LocalArtworksLoader {
        let store: ArtworksStore = try! CoreDataArtworksStore(storeURL: testSpecificStoreURL)
        let loader = LocalArtworksLoader(store: store, currentDate: { currentDate })
        
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
        
    private func validateCache(_ sut: LocalArtworksLoader, file: StaticString = #file, line: UInt = #line) {
        let result = Swift.Result { try sut.validateCache() }
        switch result {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected to validate successfully, but recieved \(error) instead.", file: file, line: line)
        }
    }
    
    var testSpecificStoreURL: URL {
        return cacheDirectory.appendingPathComponent("\(type(of: self)).store")
    }
    
}
