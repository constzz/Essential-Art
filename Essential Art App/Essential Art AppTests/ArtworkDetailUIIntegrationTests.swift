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
        
    func test_loadCompletion_rendersSuccessfullyLoadedData() {
        let artwork0 = makeArtworkDetail(title: "some title", artist: "any artist", description: "some description")
        let artwork1 = makeArtworkDetail(title: "The best", artist: "All-star")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: .none)
        
        loader.completeArtworksLoading(with: artwork0, at: 0)
        assertThat(sut, isRendering: artwork0)
        
        sut.simulateUserInitiatedReload()
        loader.completeArtworksLoading(with: artwork1, at: 1)
        assertThat(sut, isRendering: artwork1)
    }
    
    func test_loadCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let artwork0 = makeArtworkDetail(title: "some title", artist: "any artist", description: "some description")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: artwork0, at: 0)
        assertThat(sut, isRendering: artwork0)

        sut.simulateUserInitiatedReload()
        loader.completeArtworksLoadingWithError(at: 1)
        assertThat(sut, isRendering: artwork0)
    }

    func test_loadCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeArtworksLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCompletion_rendersErrorMessageOnErrorUntilNextReload() {
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
    
    // MARK: - Image View Tests
    func test_imageView_loadsImageURLWhenScreenDataLoaded() {
        let artwork0 = makeArtworkDetail(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtworkDetail(url: URL(string: "http://url-1.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        loader.completeArtworksLoading(with: artwork0, at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [artwork0.imageURL], "Expected first image URL request once screen data is loaded")
        
        sut.simulateUserInitiatedReload()
        loader.completeArtworksLoading(with: artwork1, at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [artwork0.imageURL, artwork1.imageURL], "Expected second image URL request once screen data is loaded after reload")
    }
    
    func test_imageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let artwork0 = makeArtworkDetail(url: URL(string: "http://url-0.com")!)
        let artwork1 = makeArtworkDetail(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: artwork0)
        
        XCTAssertEqual(sut.isLoadingImage, true, "Expected image loading, when detail screen content loaded. Image loading should be started")
        
        loader.completeArtworksImageLoading(at: 0)
        XCTAssertEqual(sut.isLoadingImage, false, "Expected no image loading, when image loaded.")
        
        
        sut.simulateRetryAction()
        loader.completeArtworksLoading(with: artwork1, at: 1)
        XCTAssertEqual(sut.isLoadingImage, true, "Expected image loading, when content is loaded")
    }
    
    func test_imageView_rendersImageLoadedFromURL() {
        let artwork0 = makeArtworkDetail(url: URL(string: "http://url-0.com")!)
        let artwork0Image = UIImage.make(withColor: .red).pngData()!

        let (sut, loader) = makeSUT()
        
        var renderedImage: Data? {
            sut.imageController.header.imageView.image?.pngData()
        }
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: artwork0, at: 0)

        XCTAssertEqual(renderedImage, .none, "Expected no image in image view while still loading image")
        
        loader.completeArtworksImageLoading(with: artwork0Image, at: 0)
        XCTAssertEqual(renderedImage, artwork0Image, "Expected artwork image in image view when image loaded from loader.")
    }


    func test_imageViewRetryButton_isVisibleOnImageURLLoadError() {
        let artwork0 = makeArtworkDetail(url: URL(string: "http://url-0.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.imageController.loadViewIfNeeded()
        loader.completeArtworksLoading(with: artwork0, at: 0)
        
        XCTAssertEqual(sut.isShowingImageRetryAction, false, "Expected no retry action while loading image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeArtworksImageLoading(with: imageData, at: 0)
        XCTAssertEqual(sut.isShowingImageRetryAction, false, "Expected no retry action when loaded image")
        
        sut.simulateRetryAction()
        loader.completeArtworksLoading(with: artwork0, at: 1)
        loader.completeArtworksImageLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingImageRetryAction, true, "Expected retry action state on failed image loading")
        
        sut.imageController.header.retryButton.simulate(event: .touchUpInside)
        XCTAssertEqual(sut.isShowingImageRetryAction, false, "Expected no retry button action on retry")
    }
    
    func test_imageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeArtworksLoading(with: makeArtworkDetail())
        
        XCTAssertEqual(sut.isShowingImageRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeArtworksImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(sut.isShowingImageRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }


    
    func test_deinit_cancelsRunningDetailInfoRequest() {
        var cancelCallCount = 0
        
        var sut: ArtworkDetailController?
        
        autoreleasepool {
            sut = ArtworkDetailUIComposer.artworkDetailComposedWith(
                artworkDetailLoader: {
                    PassthroughSubject<ArtworkDetail, Error>()
                        .handleEvents(receiveCancel: {
                            cancelCallCount += 1
                        }).eraseToAnyPublisher()
                },
                imageLoader: { _ in
                    PassthroughSubject<Data, Error>()
                        .eraseToAnyPublisher()
                })
            
            sut?.loadViewIfNeeded()
        }
        
        XCTAssertEqual(cancelCallCount, 0)
        
        sut = nil
        
        XCTAssertEqual(cancelCallCount, 1)
    }
    
    func test_deinit_cancelsRunningImageRequest() {
        let art = makeArtworkDetail()
        
        var sut: ArtworkDetailController?
        var loader: LoaderSpy?
        
        autoreleasepool {
            (sut, loader) = makeSUT()
            sut?.loadViewIfNeeded()
            loader?.completeArtworksLoading(with: art, at: 0)
        }
        
        sut = nil
        
        XCTAssertEqual(loader?.cancelledImageURLs, [art.imageURL])
    }

    
    // MARK: - Helpers
    
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
    
    private func makeArtworkDetail(title: String = "", artist: String = "", url: URL = URL(string: "http://any-url.com")!, description: String? = nil) -> ArtworkDetail {
        return ArtworkDetail(title: title, artist: artist, description: description, imageURL: url)
    }
    
    func assertThat(_ sut: ArtworkDetailController, isRendering artworkDetail: ArtworkDetail?, file: StaticString = #filePath, line: UInt = #line) {
        
        let expectedTitle: String? = {
            if let artworkDetail = artworkDetail {
                return artworkDetail.title + " – " + artworkDetail.artist
            } else { return nil }
        }()
        
        XCTAssertEqual(sut.titleLabel.text, expectedTitle, file: file, line: line)
        XCTAssertEqual(sut.descrpitionLabel.text, artworkDetail?.description, file: file, line: line)
    }

}

// MARK: - ArtworkDetailController test helpers
private extension ArtworkDetailController {
    
    var imageRetryButton: UIButton {
        imageController.header.retryButton
    }
    
    func tapImageRetryButton() {
        imageRetryButton.simulate(event: .touchUpInside)
    }
    
    var isShowingImageRetryAction: Bool {
        imageRetryButton.isHidden == false
    }
    
    func simulateRetryAction() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isLoadingImage: Bool {
        imageController.header.isShimmering
    }
    
    func simulateDataLoaded(_ artworkDetail: ArtworkDetail) {
        display(ArtworkDetailPresenter.map(artworkDetail))
    }
    
    var refreshControl: UIRefreshControl? {
        scrollView.refreshControl
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap() {
        errorView.simulate(event: .touchUpInside)
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    var errorMessage: String? {
        errorView.message
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

