//
//  ArtworkDetailUIIntegrationTests.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
import XCTest
import Combine
@testable import Essential_Art_iOS
import Essential_Art_App
import Essential_Art

class ArtworkDetailUIIntegrationTests: XCTestCase {
    func test_loadArtworkDetailActions_requestArtworkDtailFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadArtworksCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadArtworksCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadArtworksCount, 1, "Expected no request until previous completes")
        
        loader.completeArtworksLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadArtworksCount, 2, "Expected another loading request once user initiates a reload")
        
        loader.completeArtworksLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadArtworksCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingIndicator_isVisibleWhileLoading() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeArtworksLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeArtworksLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ArtworkDetailController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ArtworkDetailUIComposer.artworkDetailComposedWith(
            artworkDetailLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

}

// MARK: - ArtworkDetailController test helpers
private extension ArtworkDetailController {
    var refreshControl: UIRefreshControl? {
        scrollView.refreshControl
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
}

// MARK: - ArtworkDetailUIIntegrationTests + LoaderSy
private extension ArtworkDetailUIIntegrationTests {
    
    class LoaderSpy {
        
        // MARK: Artworks helpers
        
        private var artworksRequests = [PassthroughSubject<ArtworkDetail, Error>]()
        
        var loadArtworksCount: Int {
            return artworksRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<ArtworkDetail, Error> {
            let publisher = PassthroughSubject<ArtworkDetail, Error>()
            artworksRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        private var anyArtworkDetail = ArtworkDetail(title: "any ttiel", artist: "artise", description: "some desc", imageURL: URL(string: "https://test-url.com/image1.jpg")!)
        
        
        func completeArtworksLoading(with artworkDetail: ArtworkDetail? = nil, at index: Int = 0) {
            artworksRequests[index].send(artworkDetail ?? anyArtworkDetail)
            artworksRequests[index].send(completion: .finished)
        }
        
        func completeArtworksLoadingWithError(at index: Int = 0) {
            artworksRequests[index].send(completion: .failure(NSError(domain: "any-error", code: 0)))
        }
        
        
        // MARK: Image helpers
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher
                .handleEvents(receiveCancel: { [weak self] in
                    self?.cancelledImageURLs.append(url)
                })
                .eraseToAnyPublisher()
        }
        
        func completeArtworksImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].publisher.send(imageData)
            imageRequests[index].publisher.send(completion: .finished)
        }
        
        
        func completeArtworksImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].publisher.send(completion: .failure(NSError(domain: "any-error", code: 0)))
        }
        
    }
}

