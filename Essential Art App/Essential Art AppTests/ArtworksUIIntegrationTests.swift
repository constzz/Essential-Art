//
//  ArtworksUIIntegrationTests.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import Foundation
import XCTest
import Combine
import Essential_Art_iOS
import Essential_Art_App
import Essential_Art

class ArtworksUIIntegrationTests: XCTestCase {
    func test_artworksView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, ArtworkPresenter.title)
    }
    
    func test_loadArtworksActions_requestArtworksFromLoader() {
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
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingArtworks() {
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
    ) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ArtworksUIComposer.artworksComposedWith(
            artworksLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher)
        
        return (sut, loader)
    }
}

private extension ListViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension ArtworksUIIntegrationTests {
    
    class LoaderSpy {
        
        // MARK: Artworks helpers
        
        private var artworksRequests = [PassthroughSubject<Paginated<Artwork>, Error>]()
        
        var loadArtworksCount: Int {
            return artworksRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<Paginated<Artwork>, Error> {
            let publisher = PassthroughSubject<Paginated<Artwork>, Error>()
            artworksRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeArtworksLoading(with artworks: [Artwork] = [], at index: Int = 0) {
            artworksRequests[index].send(Paginated(items: artworks, loadMorePublisher: { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }))
            artworksRequests[index].send(completion: .finished)
        }
        
        func completeArtworksLoadingWithError(at index: Int = 0) {
            artworksRequests[index].send(completion: .failure(NSError(domain: "any-error", code: 0)))
        }
        
        private var loadMoreRequests = [PassthroughSubject<Paginated<Artwork>, Error>]()

        func loadMorePublisher() -> AnyPublisher<Paginated<Artwork>, Error> {
            let publisher = PassthroughSubject<Paginated<Artwork>, Error>()
            loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        
        // MARK: Image helpers
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            }).eraseToAnyPublisher()
        }

    }
}
