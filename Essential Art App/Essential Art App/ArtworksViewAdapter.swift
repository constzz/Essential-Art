//
//  ArtworksViewAdapter.swift
//  Essential Art App
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import UIKit
import Essential_Art
import Essential_Art_iOS

final class ArtworksViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> ArtworkImageStore.Publisher
    private let selection: (Artwork) -> Void
    private let currentArtworks: [Artwork: CellController]
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<ArtworksItemCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<Artwork>, ArtworksViewAdapter>
    
    init(
        currentArtworks: [Artwork: CellController] = [:],
        controller: ListViewController,
        imageLoader: @escaping (URL) -> ArtworkImageStore.Publisher,
        selection: @escaping (Artwork) -> Void
    ) {
        self.currentArtworks = currentArtworks
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<Artwork>) {
        guard let controller = controller else { return }
        
        var currentArtworks = self.currentArtworks
        let feed: [CellController] = viewModel.items.map { model in
            if let controller = currentArtworks[model] {
                return controller
            }
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.imageURL)
            })
            
            let view = ArtworksItemCellController(
                viewModel: ArtworkImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                resourceView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            let controller = CellController(id: model, view)
            currentArtworks[model] = controller
            return controller
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(loadMore),
            errorView: WeakRefVirtualProxy(loadMore),
            resourceView: ArtworksViewAdapter(
                currentArtworks: currentArtworks,
                controller: controller,
                imageLoader: imageLoader,
                selection: selection
            ))
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller.display(feed, loadMoreSection)
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
