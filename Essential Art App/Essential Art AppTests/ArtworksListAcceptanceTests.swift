//
//  ArtworksListAcceptanceTests.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 23.11.2022.
//

import Foundation
@testable import Essential_Art_App
import Essential_Art
@testable import Essential_Art_iOS
import XCTest

class ArtworksListAcceptanceTests: XCTestCase {
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let artworks = launch(
			httpClient: .online(response),
			store: .empty)

		artworks.loadViewIfNeeded()

		XCTAssertEqual(artworks.numberOfRenderedArtworks(), 1)
		XCTAssertEqual(artworks.renderedFeedImageData(at: 0), imageData0)
		XCTAssertTrue(artworks.canLoadMoreFeed)

		artworks.simulateLoadMoreArtworksAction()

		XCTAssertEqual(artworks.numberOfRenderedArtworks(), 2)
		XCTAssertEqual(artworks.renderedFeedImageData(at: 0), imageData0)
		XCTAssertEqual(artworks.renderedFeedImageData(at: 1), imageData1)
		XCTAssertTrue(artworks.canLoadMoreFeed)

		artworks.simulateLoadMoreArtworksAction()

		XCTAssertEqual(artworks.numberOfRenderedArtworks(), 3)
		XCTAssertEqual(artworks.renderedFeedImageData(at: 0), imageData0)
		XCTAssertEqual(artworks.renderedFeedImageData(at: 1), imageData1)
		XCTAssertEqual(artworks.renderedFeedImageData(at: 2), imageData2)
		XCTAssertFalse(artworks.canLoadMoreFeed)
	}

	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let sharedStore = InMemoryArtworksStore.empty

		let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
		onlineFeed.simulateLoadMoreArtworksAction()
		onlineFeed.simulateLoadMoreArtworksAction()
		XCTAssertNotNil(onlineFeed.simulateArtworkImageViewVisible(at: 0))
		XCTAssertNotNil(onlineFeed.simulateArtworkImageViewVisible(at: 1))
		XCTAssertNotNil(onlineFeed.simulateArtworkImageViewVisible(at: 2))

		let offlineFeed = launch(httpClient: .offline, store: sharedStore)

		XCTAssertEqual(offlineFeed.numberOfRenderedArtworks(), 3)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), imageData0)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), imageData1)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), imageData2)
		XCTAssertFalse(offlineFeed.canLoadMoreFeed)
	}

	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let artworks = launch(httpClient: .offline, store: .empty)

		XCTAssertEqual(artworks.numberOfRenderedArtworks(), 0)
	}

	func test_onEnteringBackground_deletesExpiredFeedCache() {
		let store = InMemoryArtworksStore.withExpiredFeedCache

		enterBackground(with: store)

		XCTAssertNil(store.artworksCache, "Expected to delete expired cache")
	}

	func test_onEnteringBackground_keepsNonExpiredFeedCache() {
		let store = InMemoryArtworksStore.withNonExpiredFeedCache

		enterBackground(with: store)

		XCTAssertNotNil(store.artworksCache, "Expected to keep non-expired cache")
	}

	func test_onArtworkImageSelection_displaysDetail() {
		let artworkDetail = showDetailForFirstArtwork()
		artworkDetail.loadViewIfNeeded()

		artworkDetail.assertIsRendering(isRendering: firstArtworkDetail)
	}

	// MARK: - Helpers

	private func showDetailForFirstArtwork() -> ArtworkDetailController {
		let artworks = launch(httpClient: .online(response), store: .empty)

		artworks.simulateTapOnArtwork(at: 0)
		RunLoop.current.run(until: Date())

		let nav = artworks.navigationController
		return nav?.topViewController as! ArtworkDetailController
	}

	private func enterBackground(with store: InMemoryArtworksStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store, scheduler: .immediateOnMainQueue, artworksLimitPerPage: 10)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}

	private var imageData0: Data = UIImage.make(withColor: .red).pngData()!
	private var imageData1: Data = UIImage.make(withColor: .green).pngData()!
	private var imageData2: Data = UIImage.make(withColor: .blue).pngData()!
	private var imageData3: Data = UIImage.make(withColor: .brown).pngData()!

	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}

	private lazy var firstArtworkDetail = ArtworkDetail(
		title: "title",
		artist: "artist",
		description: "any description",
		imageURL: baseURL)

	private let baseURL = URL(string: "http://url-0.com")!

	lazy var imageDataForURLPath: [String: Data] = [
		"/0123/full/843,/0/default.jpg": imageData0,
		"/3273/full/843,/0/default.jpg": imageData1,
		"/32923/full/843,/0/default.jpg": imageData2,
		"/44944/full/843,/0/default.jpg": imageData3
	]

	private func artworkWithImageID(_ imageID: String, customID: Int? = nil) -> [String: Any] {
		return ["image_id": "\(imageID)", "artist_display": "artist", "title": "title", "id": customID ?? UUID().hashValue]
	}

	private func artworksDataForPage(_ page: Int) -> [[String: Any]] {
		switch page {
		case 0:
			return [artworkWithImageID("0123", customID: 0)]
		case 1:
			return [artworkWithImageID("3273")]
		case 2:
			return [artworkWithImageID("32923")]
		default:
			return []
		}
	}

	private func makeData(for url: URL) -> Data {
		switch url.path {
		case _ where imageDataForURLPath[url.path] != nil:
			return imageDataForURLPath[url.path]!

		case "/api/v1/artworks":

			var page: Int!

			var artworks: [[String: Any]] = []

			if url.query?.contains("page=0") ?? false {
				page = 0
				artworks = artworksDataForPage(0)
			} else if url.query?.contains("page=1") ?? false {
				page = 1
				artworks = artworksDataForPage(1)
			} else if url.query?.contains("page=2") ?? false {
				page = 2
				artworks = artworksDataForPage(2)
			} else { XCTFail("Not expected case") }

			let json = [
				"data": artworks,
				"config": [
					"iiif_url": "http://any-url.com"
				],
				"pagination": [
					"total_pages": 3,
					"current_page": page
				]
			] as [String: Any]
			return try! JSONSerialization.data(withJSONObject: json)

		case "/api/v1/artworks/0":
			let detailJSON = [
				"data": [
					"image_id": "0",
					"artist_display": firstArtworkDetail.artist,
					"title": firstArtworkDetail.title,
					"thumbnail": [
						"alt_text": firstArtworkDetail.description
					]
				],
				"config": [
					"iiif_url": baseURL.absoluteString
				]
			]
			return try! JSONSerialization.data(withJSONObject: detailJSON)

		default:
			return Data()
		}
	}

	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryArtworksStore = .empty,
		artworksLimitPerPage: Int = 1
	) -> ListViewController {
		let sut = SceneDelegate(
			httpClient: httpClient,
			store: store,
			scheduler: .immediateOnMainQueue,
			artworksLimitPerPage: artworksLimitPerPage)

		sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		sut.configureWindow()

		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! ListViewController
	}
}

extension ArtworkDetailController {
	func assertIsRendering(isRendering artworkDetail: ArtworkDetail?, file: StaticString = #file, line: UInt = #line) {
		let expectedTitle: String? = {
			if let artworkDetail = artworkDetail {
				return artworkDetail.title + " – " + artworkDetail.artist
			} else { return nil }
		}()

		XCTAssertEqual(titleLabel.text, expectedTitle, file: file, line: line)
		XCTAssertEqual(descrpitionLabel.text, artworkDetail?.description, file: file)
	}
}
