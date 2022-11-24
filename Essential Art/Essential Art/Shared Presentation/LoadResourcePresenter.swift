//
//  LoadResourcePresenter.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation

public protocol ResourceView {
	associatedtype ResourceViewModel

	func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {

	public typealias Mapper = (Resource) throws -> View.ResourceViewModel
	private let loadingView: ResourceLoadingView
	private let errorView: ResourceErrorView
	private let resourceView: View
	private let mapper: Mapper

	public init(
		loadingView: ResourceLoadingView,
		errorView: ResourceErrorView,
		resourceView: View,
		mapper: @escaping Mapper
	) {
		self.loadingView = loadingView
		self.errorView = errorView
		self.resourceView = resourceView
		self.mapper = mapper
	}

	public init(
		loadingView: ResourceLoadingView,
		errorView: ResourceErrorView,
		resourceView: View
	) where Resource == View.ResourceViewModel {
		self.loadingView = loadingView
		self.errorView = errorView
		self.resourceView = resourceView
		self.mapper = { $0 }
	}

	public static var loadError: String {
		NSLocalizedString("GENERIC_CONNECTION_ERROR",
		                  tableName: "Shared",
		                  bundle: Bundle(for: Self.self),
		                  comment: "Error message displayed when we can't load the resource from the server")
	}

	public func didStartLoading() {
		errorView.display(.noError)
		loadingView.display(.init(isLoading: true))
	}

	public func didFinishLoading(with resource: Resource) {
		do {
			resourceView.display(try mapper(resource))
			loadingView.display(.init(isLoading: false))
		} catch {
			didFinishLoading(with: error)
		}
	}

	public func didFinishLoading(with error: Error) {
		errorView.display(.init(errorMessage: Self.loadError))
		loadingView.display(.init(isLoading: false))
	}
}
