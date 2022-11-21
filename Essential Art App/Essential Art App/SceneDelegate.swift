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
    
    private lazy var localArtworksLoader: LocalArtworksLoader = {
        LocalArtworksLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: ArtworksUIComposer.artworksComposedWith(
            artworksLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: {_ in
                let subj = PassthroughSubject<Data, Error>()
                subj.send(completion: .failure(NSError(domain: "", code: 3)))
                return subj.eraseToAnyPublisher()
            }))


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


