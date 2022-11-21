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
    
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingLoadMoreArtworksIndicator, "Expected no loading indicator once view is loaded")
        
        loader.completeArtworksLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreArtworksIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertTrue(sut.isShowingLoadMoreArtworksIndicator, "Expected loading indicator on load more action")
        
        loader.completeLoadMore(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreArtworksIndicator, "Expected no loading indicator once user initiated loading completes successfully")
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertTrue(sut.isShowingLoadMoreArtworksIndicator, "Expected loading indicator on second load more action")
        
        loader.completeArtworksLoadingMoreWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadMoreArtworksIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(at: 0)
        sut.simulateLoadMoreArtworksAction()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoadMore()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMoreCompletion_rendersErrorMessageOnError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading()
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(sut.loadMoreArtworksErrorMessage, nil)
        
        loader.completeArtworksLoadingMoreWithError()
        XCTAssertEqual(sut.loadMoreArtworksErrorMessage, loadError)
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(sut.loadMoreArtworksErrorMessage, nil)
    }
    
    func test_tapOnLoadMoreErrorView_loadsMore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading()
        
        sut.simulateLoadMoreArtworksAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        sut.simulateTapOnLoadMoreArtworksError()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        loader.completeArtworksLoadingMoreWithError()
        sut.simulateTapOnLoadMoreArtworksError()
        XCTAssertEqual(loader.loadMoreCallCount, 2)
    }

    // MARK: - Image View Tests
    
    func test_artworksImageView_loadsImageURLWhenVisible() {
        let artwork0 = makeArtwork(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtwork(url: URL(string: "http://url-1.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0, artwork1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateArtworkImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [artwork0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateArtworkImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [artwork0.imageURL, artwork1.imageURL], "Expected second image URL request once second view also becomes visible")
    }

    func test_artworkView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let artwork0 = makeArtwork(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtwork(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0, artwork1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateArtworkImageViewIsNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [artwork0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateArtworkImageViewIsNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [artwork0.imageURL, artwork1.imageURL], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }

    func test_artworkImageView_reloadsImageURLWhenBecomingVisibleAgain() {
        let artwork0 = makeArtwork(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtwork(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0, artwork1])
        
        sut.simulateFeedImageBecomingVisibleAgain(at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [artwork0.imageURL, artwork0.imageURL], "Expected two image URL request after first view becomes visible again")
        
        sut.simulateFeedImageBecomingVisibleAgain(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [artwork0.imageURL, artwork0.imageURL, artwork1.imageURL, artwork1.imageURL], "Expected two new image URL request after second view becomes visible again")
    }
    
    func test_artworkImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let artwork0 = makeArtwork(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtwork(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0, artwork1])
        
        let view0 = sut.simulateArtworkImageViewVisible(at: 0)
        let view1 = sut.simulateArtworkImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeArtworksImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeArtworksImageLoading(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")

        view1?.simulateRetryAction()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator state change for second view on retry action")
    }

    func test_artworkImageView_rendersImageLoadedFromURL() {
        let artwork0 = makeArtwork(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtwork(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: [artwork0, artwork1])
        
        let view0 = sut.simulateArtworkImageViewVisible(at: 0)
        let view1 = sut.simulateArtworkImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeArtworksImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .green).pngData()!
        loader.completeArtworksImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }


    private func makeArtwork(title: String = "", artist: String = "", url: URL = URL(string: "http://any-url.com")!) -> Artwork {
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

private extension ArworkItemCell {
    var isShowingImageLoadingIndicator: Bool {
        artworkImageView.isShimmering
    }
    
    func simulateRetryAction() {
        artworkImageRetryButton.simulate(event: .touchUpInside)
    }
    
    var renderedImage: Data? {
        return artworkImageView.image?.pngData()
    }
}

private extension ListViewController {
    
    @discardableResult
    func simulateArtworkImageViewVisible(at index: Int) -> ArworkItemCell? {
        cell(row: index, section: artworksSection) as? ArworkItemCell
    }
    
    @discardableResult
    func simulateArtworkImageViewIsNotVisible(at row: Int) -> ArworkItemCell? {
        let view = simulateArtworkImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: artworksSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> ArworkItemCell? {
        let view = simulateArtworkImageViewIsNotVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: artworksSection)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
    
    var loadMoreArtworksErrorMessage: String? {
        return loadMoreFeedCell()?.message
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func simulateTapOnLoadMoreArtworksError() {
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
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
    
    var isShowingLoadMoreArtworksIndicator: Bool {
        loadMoreFeedCell()?.isLoading ?? false
    }
    
    func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: loadMoreSection) as? LoadMoreCell
    }
    
    var artworksSection: Int { 0 }
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
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            }).eraseToAnyPublisher()
        }
        
        func completeArtworksImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].publisher.send(imageData)
            imageRequests[index].publisher.send(completion: .finished)
        }


    }
}
