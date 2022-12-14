//
//  ArtworsSnapshotTests.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import Foundation
import XCTest
import Essential_Art_iOS
@testable import Essential_Art

class ArtworsSnapshotTests: XCTestCase {
	func test_artworksWithContent() {
		let sut = makeSUT()

		sut.display(artworksItems())

		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORKS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORKS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "ARTWORKS_WITH_CONTENT_light_extraExtraExtraLarge")
	}

	func test_artworksWithFailedImageLoading() {
		let sut = makeSUT()

		sut.display(failedArtworksItems())

		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORKS_WITH_FAILED_IMAGE_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORKS_WITH_FAILED_IMAGE_LOADING_dark")
	}

	func test_artworksWithLoadMoreIndicator() {
		let sut = makeSUT()

		sut.display(artworksWithLoadMoreIndicator())

		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORKS_WITH_LOAD_MORE_INDICATOR_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORKS_WITH_LOAD_MORE_INDICATOR_dark")
	}

	func test_artworksWithLoadMoreError() {
		let sut = makeSUT()

		sut.display(loadMoreError())

		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "ARTWORKS_WITH_LOAD_MORE_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "ARTWORKS_WITH_LOAD_MORE_ERROR_dark")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "ARTWORKS_WITH_LOAD_MORE_ERROR_extraExtraExtraLarge")
	}

	private func makeSUT() -> ListViewController {
		let viewController = ArtworksController()
		viewController.loadViewIfNeeded()
		viewController.tableView.separatorStyle = .none
		viewController.tableView.showsVerticalScrollIndicator = false
		viewController.tableView.showsHorizontalScrollIndicator = false
		return viewController
	}

	private func artworksItems() -> [CellController] {
		return artworksWithContent().map { stub in
			let cellController = ArtworksItemCellController(
				viewModel: stub.viewModel,
				delegate: stub,
				selection: {})
			stub.controller = cellController
			return CellController(id: UUID(), cellController)
		}
	}

	private func artworksWithContent() -> [ImageStub] {
		return [
			ImageStub(title: "The very high building",
			          artist: "Architect",
			          image: UIImage(data: architecturePhotoSample1.data)),
			ImageStub(title: "Sandbox",
			          artist: "Another artist",
			          image: UIImage(data: architecturePhotoSample2.data))
		]
	}

	private func failedArtworksItems() -> [CellController] {
		return artworksWithContent().map { stub in
			let cellController = ArtworksItemCellController(
				viewModel: stub.viewModel,
				delegate: stub,
				selection: {})
			stub.controller = cellController
			return CellController(id: UUID(), cellController)
		}
	}

	private func artworksWithLoadMoreIndicator() -> [CellController] {
		let loadMore = LoadMoreCellController(callback: {})
		loadMore.display(ResourceLoadingViewModel(isLoading: true))
		return artworksWith(loadMore: loadMore)
	}

	private func loadMoreError() -> [CellController] {
		let loadMore = LoadMoreCellController(callback: {})
		loadMore.display(ResourceErrorViewModel(errorMessage: "Multiline \n error \nmessage"))
		return artworksWith(loadMore: loadMore)
	}

	private func artworksWith(loadMore: LoadMoreCellController) -> [CellController] {
		let stub = artworksWithContent().last!
		let cellController = ArtworksItemCellController(
			viewModel: stub.viewModel,
			delegate: stub,
			selection: {})
		stub.controller = cellController

		return [
			CellController(id: UUID(), cellController),
			CellController(id: UUID(), loadMore)
		]
	}
}

private class ImageStub: ArtworksItemCellControllerDelegate {
	let viewModel: ArtworkItemViewModel
	let image: UIImage?
	weak var controller: ArtworksItemCellController?

	init(title: String, artist: String, image: UIImage?) {
		self.viewModel = ArtworkItemViewModel(title: title, artist: artist)
		self.image = image
	}

	func didRequestImage() {
		controller?.display(ResourceLoadingViewModel(isLoading: false))

		if let image = image {
			controller?.display(image)
			controller?.display(ResourceErrorViewModel(errorMessage: .none))
		} else {
			controller?.display(ResourceErrorViewModel(errorMessage: "message"))
		}
	}

	func didCancelImageRequest() {}
}
