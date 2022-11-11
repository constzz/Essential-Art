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
