//
//  ListViewController+TestHelpers.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 23.11.2022.
//

import Foundation
import Essential_Art
@testable import Essential_Art_iOS
import XCTest

extension ListViewController {
	private var artworkSection: Int { 0 }

	func simulateTapOnArtwork(at index: Int) {
		let delegate = tableView.delegate
		let index = IndexPath(row: index, section: artworksSection)
		delegate?.tableView?(tableView, didSelectRowAt: index)
	}

	func numberOfRenderedArtworks() -> Int {
		numberOfRows(in: artworkSection)
	}

	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateArtworkImageViewVisible(at: index)?.artworkImageView.image?.pngData()
	}

	var canLoadMoreFeed: Bool {
		loadMoreFeedCell() != nil
	}

	func simulateArtworkViewNotNearVisible(at row: Int) {
		simulateArtworkViewNearVisible(at: row)

		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: artworksSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}

	func simulateArtworkViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: artworksSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}

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
	func simulateArtworkImageBecomingVisibleAgain(at row: Int) -> ArworkItemCell? {
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
