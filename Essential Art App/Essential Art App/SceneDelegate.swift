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
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}


