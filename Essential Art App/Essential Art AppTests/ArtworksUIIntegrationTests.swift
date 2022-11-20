//
//  ArtworksUIIntegrationTests.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import Foundation
import XCTest
import Essential_Art_iOS
import Essential_Art_App
import Essential_Art

class ArtworksUIIntegrationTests: XCTestCase {
    func test_artworksView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, ArtworkPresenter.title)
    }
    
    private func makeSUT() -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ArtworksUIComposer.artworksComposedWith()
        
        return (sut, loader)
    }
}

private extension ArtworksUIIntegrationTests {
    class LoaderSpy {
        
    }
}
