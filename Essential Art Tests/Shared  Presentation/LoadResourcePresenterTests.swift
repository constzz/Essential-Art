//
//  LoadResourcePresenterTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation
import XCTest

struct ResourceLoadingViewModel {
    let isLoading: Bool
}

protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

struct ResourceErrorViewModel {
    let errorMessage: String?
    static let noError = ResourceErrorViewModel(errorMessage: nil)
}

protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    private let resourceView: View
    private let mapper: Mapper
    
    init(
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
    
    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(.init(isLoading: false))
    }
}

class LoadResourcePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoadingResource_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any"}
    ) -> (SUT, ViewSpy) {
        let view = ViewSpy()
        let presenter = SUT(loadingView: view, errorView: view, resourceView: view, mapper: mapper)
        return (presenter, view)
    }
    
    class ViewSpy: ResourceLoadingView, ResourceErrorView, ResourceView {
        typealias ResourceViewModel = String
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(errorMessage: String?)
            case display(resourceViewModel: ResourceViewModel)
        }
        
        var messages = [Message]()
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.errorMessage))
        }
        
        func display(_ viewModel: ResourceViewModel) {
            messages.append(.display(resourceViewModel: viewModel))
        }
    }
}
