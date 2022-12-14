//
//  ArtworkDetailUIComposer.swift
//  Essential Art App
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import UIKit
import Combine
import Essential_Art
import Essential_Art_iOS

public final class ArtworkDetailUIComposer {
	private init() {}

	private typealias PresentationAdapter = LoadResourcePresentationAdapter<ArtworkDetail, ArtworkDetailViewAdapter>

	public static func artworkDetailComposedWith(
		artworkDetailLoader: @escaping () -> AnyPublisher<ArtworkDetail, Error>,
		imageLoader: @escaping (URL) -> ArtworkImageStore.Publisher
	) -> ArtworkDetailController {
		let viewController = makeArtworkDetailController()

		let presentationAdapter = PresentationAdapter(loader: artworkDetailLoader)

		viewController.onRefresh = presentationAdapter.loadResource

		presentationAdapter.presenter = LoadResourcePresenter(
			loadingView: WeakRefVirtualProxy(viewController),
			errorView: WeakRefVirtualProxy(viewController),
			resourceView: ArtworkDetailViewAdapter(
				controller: viewController,
				imageController: viewController.imageController,
				imageLoader: imageLoader))

		return viewController
	}

	private static func makeArtworkDetailController() -> ArtworkDetailController {
		let viewController = ArtworkDetailController()
		return viewController
	}
}

final class ArtworkDetailViewAdapter: ResourceView {
	private weak var controller: ArtworkDetailController?
	private weak var imageController: ArtworkDetailImageController?
	private let imageLoader: (URL) -> ArtworkImageStore.Publisher

	private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<ArtworkDetailImageController>>

	init(
		controller: ArtworkDetailController,
		imageController: ArtworkDetailImageController,
		imageLoader: @escaping (URL) -> ArtworkImageStore.Publisher
	) {
		self.controller = controller
		self.imageController = imageController
		self.imageLoader = imageLoader
	}

	func display(_ viewModel: ArtworkDetail) {
		guard let controller = controller else { return }

		controller.display(ArtworkDetailPresenter.map(viewModel))

		guard let imageController = imageController else { return }

		let imageDataPresentationAdapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
			imageLoader(viewModel.imageURL)
		})

		imageDataPresentationAdapter.presenter = .init(
			loadingView: WeakRefVirtualProxy(imageController),
			errorView: WeakRefVirtualProxy(imageController),
			resourceView: WeakRefVirtualProxy(imageController),
			mapper: UIImage.tryMake)

		imageDataPresentationAdapter.didRequestImage()

		imageController.delegate = imageDataPresentationAdapter
	}
}
