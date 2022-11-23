//
//  ArtworkDetailSnapshotTests.swift
//  Essential Art iOS Tests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
@testable import Essential_Art
import Essential_Art_iOS
import UIKit
import XCTest

class ArtworkDetailSnapshotTests: XCTestCase {
    
    // MARK: - Content loading
    func test_artworkDetailWithContent() {
        let sut = makeSUT(viewModel: fullContent())
        
        sut.imageController.display(.make(withColor: .red))
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORK_DETAIL_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORK_DETAIL_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "ARTWORK_DETAIL_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_artworkDetailWithContentNoDescription() {
        let sut = makeSUT(viewModel: noDescription())
        
        sut.imageController.display(.make(withColor: .red))
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORK_DETAIL_WITH_CONTENT_NO_DESCRIPTION_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORK_DETAIL_WITH_CONTENT_NO_DESCRIPTION_dark")
    }
    
    func test_artworkDetailWithContentLoading() {
        let sut = makeSUT()
        
        sut.display(ResourceLoadingViewModel(isLoading: true))
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORK_DETAIL_LOADING_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORK_DETAIL_LOADING_CONTENT_dark")
    }

    
    // MARK: - Image loading
    func test_artworkDetailWithFailedImageLoading() {
        let sut = makeSUT(viewModel: fullContent())
        
        sut.imageController.display(ResourceErrorViewModel(errorMessage: "Any image failing message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORK_DETAIL_FAILED_IMAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORK_DETAIL_FAILED_IMAGE_dark")
    }

    

    // MARK: - Helpers
    
    private func makeSUT(viewModel: ArtworkDetailViewModel? = nil) -> ArtworkDetailController {
        let viewController = ArtworkDetailController()
        viewController.loadViewIfNeeded()
        if let viewModel = viewModel {
            viewController.display(viewModel)
        }
        return viewController
    }
    
    private func fullContent() -> ArtworkDetailViewModel {
        return .init(
            title: "Some title there",
            artist: "Leonardo Lewandowski",
            description: "Abstract painting composed of small vertical dabs of multiple shades of blue with a small area of similar strokes of red, orange, and yellow in the upper right."
        )
    }
    
    private func noDescription() -> ArtworkDetailViewModel {
        return .init(
            title: "Some title there",
            artist: "Leonardo Lewandowski",
            description: nil
        )
    }
}
