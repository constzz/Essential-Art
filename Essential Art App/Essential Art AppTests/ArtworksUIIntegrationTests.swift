//
//  ArtworksUIIntegrationTests.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import Foundation
import XCTest
import Combine
@testable import Essential_Art_iOS
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
        
    func test_loadArtworksCompletion_rendersSuccessfullyLoadedArtworks() {
        let artwork0 = makeArtwork(title: "some title", artist: "any artiss")
        let artwork1 = makeArtwork(title: "The best", artist: "All-star")
        let artwork2 = makeArtwork(title: "Another one", artist: "Leonardo")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeArtworksLoading(with: [artwork0, artwork1], at: 0)
        assertThat(sut, isRendering: [artwork0, artwork1])
        
        sut.simulateLoadMoreArtworksAction()
        loader.completeLoadMore(with: [artwork2, artwork0, artwork1], at: 0)
        assertThat(sut, isRendering: [artwork2, artwork0, artwork1])
        
        sut.simulateUserInitiatedReload()
        loader.completeArtworksLoading(with: [artwork0, artwork1], at: 1)
        assertThat(sut, isRendering: [artwork0, artwork1])
    }
    
    func test_loadArtworksCompletion_rendersSuccessfullyLoadedEmptArtworksAfterNonEmptyArtworks() {
        let artwork0 = makeArtwork(title: "some title", artist: "any artiss")
        let artwork1 = makeArtwork(title: "The best", artist: "All-star")

        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0], at: 0)
        assertThat(sut, isRendering: [artwork0])
        
        sut.simulateLoadMoreArtworksAction()
        loader.completeLoadMore(with: [artwork0, artwork1], at: 0)
        assertThat(sut, isRendering: [artwork0, artwork1])
        
        sut.simulateUserInitiatedReload()
        loader.completeArtworksLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadArtworksCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let artwork0 = makeArtwork(title: "some title", artist: "any artiss")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0], at: 0)
        assertThat(sut, isRendering: [artwork0])
        
        sut.simulateUserInitiatedReload()
        loader.completeArtworksLoadingWithError(at: 1)
        assertThat(sut, isRendering: [artwork0])
        
        sut.simulateLoadMoreArtworksAction()
        loader.completeArtworksLoadingWithError(at: 0)
        assertThat(sut, isRendering: [artwork0])
    }
    
    func test_loadArtworksCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeArtworksLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadArtworksCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeArtworksLoadingWithError(at: 0)

        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeArtworksLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: - Load More Tests
    
    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading()
        
        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no requests before until load more action")
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while loading more")
        
        loader.completeLoadMore(lastPage: false, at: 0)
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")
        
        loader.completeArtworksLoadingMoreWithError(at: 1)
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")
        
        loader.completeLoadMore(lastPage: true, at: 2)
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
    }


    private func makeArtwork(title: String, artist: String, url: URL = URL(string: "http://any-url.com")!) -> Artwork {
        return Artwork(title: title, imageURL: url, artist: artist)
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
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
    
    var errorMessage: String? {
        errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func simulateErrorViewTap() {
        errorView.simulate(event: .touchUpInside)
    }
    
    func simulateLoadMoreArtworksAction() {
        guard let view = loadMoreFeedCell() else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: loadMoreSection) as? LoadMoreCell
    }
    
    var loadMoreSection: Int { 1 }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

// MARK: - ArtworksUIIntegrationTests + Assertions
private extension ArtworksUIIntegrationTests {
    
    var artworksSection: Int { 0 }
    
    func assertThat(_ sut: ListViewController, isRendering artworks: [Artwork], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRows(in: artworksSection) == artworks.count else {
            return XCTFail("Expected \(artworks.count) artworks, got \(sut.numberOfRows(in: artworksSection)) instead.", file: file, line: line)
        }
        
        artworks.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor artwork: Artwork, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.cell(row: index, section: artworksSection)
        
        guard let cell = view as? ArworkItemCell else {
            return XCTFail("Expected \(ArworkItemCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.artistLabel.text, artwork.artist, file: file, line: line)
        XCTAssertEqual(cell.titleLabel.text, artwork.title, file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }

}

// MARK: - ArtworksUIIntegrationTests + LoaderSy
private extension ArtworksUIIntegrationTests {
    
    class LoaderSpy {
        
        // MARK: Artworks helpers
        
        private var artworksRequests = [PassthroughSubject<Paginated<Artwork>, Error>]()
        
        var loadArtworksCount: Int {
            return artworksRequests.count
        }
        
        var loadMoreCallCount: Int {
            loadMoreRequests.count
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
        
        func completeLoadMore(with artworks: [Artwork] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMoreRequests[index].send(Paginated(
                items: artworks,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                }))
        }
        
        func completeArtworksLoadingMoreWithError(at index: Int = 0) {
            loadMoreRequests[index].send(completion: .failure(NSError(domain: "any-error", code: 0)))
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
