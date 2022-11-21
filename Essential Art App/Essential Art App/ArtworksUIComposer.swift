//
//  ArtworksUIComposer.swift
//  Essential Art App
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import UIKit
import Combine
import Essential_Art
import Essential_Art_iOS

public final class ArtworksUIComposer {
    private init () {}
    
    private typealias PresentationAdapter = LoadResourcePresentationAdapter<Paginated<Artwork>, ArtworksViewAdapter>
    
    public static func artworksComposedWith(
        artworksLoader: @escaping () -> AnyPublisher<Paginated<Artwork>, Error>,
        imageLoader: @escaping (URL) -> ArtworkImageDataLoader.Publisher,
        selection: @escaping (Artwork) -> Void = { _ in }
    ) -> ListViewController {
        let viewController = makeArtworksViewController(title: ArtworkPresenter.title)
        
        let presentationAdapter = PresentationAdapter(loader: artworksLoader)
        
        viewController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(viewController),
            errorView: WeakRefVirtualProxy(viewController),
            resourceView: ArtworksViewAdapter(
                controller: viewController,
                imageLoader: imageLoader,
                selection: selection))
        
        return viewController
    }

    private static func makeArtworksViewController(title: String) -> ListViewController {
        let viewController = ArtworksController() as ListViewController
        viewController.title = title
        return viewController
    }
    
}

public protocol ArtworkImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}

extension ArtworkImageDataLoader {
    public typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        return Deferred {
            Future { completion in
                completion(Result {
                    try self.loadImageData(from: url)
                })
            }
        }
        .eraseToAnyPublisher()
    }
}
