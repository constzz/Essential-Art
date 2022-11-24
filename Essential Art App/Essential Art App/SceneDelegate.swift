//
//  SceneDelegate.swift
//  Essential Art App
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import UIKit
import os
import Essential_Art_iOS
import Essential_Art
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
		label: "com.konstantin.bezzemelnyi.infra.queue",
		qos: .userInitiated,
		attributes: .concurrent
	).eraseToAnyScheduler()

	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()

	private lazy var logger = Logger(subsystem: "com.konstantin.bezzemelnyi.EssentialArtwork", category: "main")

	private lazy var baseURL = URL(string: "https://api.artic.edu")!

	private lazy var store: ArtworksStore = {
		do {
			return try CoreDataArtworksStore(
				storeURL: NSPersistentContainer
					.defaultDirectoryURL()
					.appendingPathComponent("feed-store.sqlite"))
		} catch {
			assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
			logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
			return NullStore()
		}
	}()

	private lazy var localImageStore: ArtworkImageStore = {
		let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
		let cache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
		logger.info("Cache path: \(diskCacheURL.path)")

		return URLCacheArtworkImageStore(cache: cache)
	}()

	private lazy var localArtworksLoader: LocalArtworksLoader = {
		LocalArtworksLoader(store: store, currentDate: Date.init)
	}()

	private lazy var navigationController = UINavigationController(
		rootViewController: ArtworksUIComposer.artworksComposedWith(
			artworksLoader: makeRemoteFeedLoaderWithLocalFallback,
			imageLoader: imageLoader,
			selection: showDetails))

	private typealias ImageLoader = (URL) -> AnyPublisher<Data, Swift.Error>
	private lazy var imageLoader: ImageLoader = makeLocalImageLoaderWithRemoteFallback

	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> AnyPublisher<Data, Swift.Error> {
		localImageStore
			.loadImageDataPublisher(from: url)
			.fallback(to: { [httpClient, scheduler] in
				httpClient
					.getPublisher(url: url)
					.tryMap(ArticImageDataMapper.map)
					.caching(to: self.localImageStore)
					.map { $0.data }
					.subscribe(on: scheduler)
					.eraseToAnyPublisher()
			})
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }

		window = UIWindow(windowScene: scene)
		configureWindow()
	}

	func sceneWillResignActive(_ scene: UIScene) {
		do {
			try localArtworksLoader.validateCache()
		} catch {
			logger.error("Failed to validate cache with error: \(error.localizedDescription)")
		}
	}

	func configureWindow() {
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
}

// MARK: - Artwork Details Screen
private extension SceneDelegate {

	func showDetails(artwork: Artwork) {
		let artworkDetailLoader = makeArtworkDetailLoader(artworkID: artwork.id)
		let viewController = ArtworkDetailUIComposer.artworkDetailComposedWith(
			artworkDetailLoader: { artworkDetailLoader },
			imageLoader: imageLoader)
		navigationController.pushViewController(viewController, animated: true)
	}

	private func makeArtworkDetailLoader(artworkID: Int) -> AnyPublisher<ArtworkDetail, Error> {
		let url = ArtworkDetailEndpoint.get(id: artworkID).url(baseURL: baseURL)
		return httpClient
			.getPublisher(url: url)
			.tryMap(ArtworkDetailMapper.map)
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
	}
}

// MARK: - Artworks Screen
private extension SceneDelegate {

	enum Constants {
		static let firstPage = 0
		static let limit = 10
	}

	func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<Artwork>, Error> {
		makeRemoteFeedLoader(page: Constants.firstPage)
			.caching(to: localArtworksLoader)
			.fallback(to: localArtworksLoader.loadPublisher)
			.map({ self.makePage(artworks: $0, page: Constants.firstPage) })
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
	}

	func makeRemoteFeedLoader(page: Int? = nil) -> AnyPublisher<[Artwork], Error> {
		let url = ArticEndpoint.get(page: page, limit: Constants.limit).url(baseURL: baseURL)

		return httpClient
			.getPublisher(url: url)
			.tryMap(ArtworkMapper.map)
			.eraseToAnyPublisher()
	}

	func makePage(artworks: [Artwork], page: Int) -> Paginated<Artwork> {
		Paginated(
			items: artworks,
			loadMorePublisher: { self.makeRemoteLoadMoreLoader(previousArtworks: artworks, forPage: page + 1) }
		)
	}

	func makeRemoteLoadMoreLoader(previousArtworks: [Artwork], forPage page: Int) -> AnyPublisher<Paginated<Artwork>, Error> {
		let newPage = page + 1
		return makeRemoteFeedLoader(page: newPage)
			.map { newItems in
				(previousArtworks + newItems, newPage)
			}
			.map(makePage)
			.caching(to: localArtworksLoader)
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
	}
}
