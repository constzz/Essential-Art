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

final class LoadResourcePresenter {
    
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    init(loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
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
    
    private func makeSUT() -> (LoadResourcePresenter, ViewSpy) {
        let view = ViewSpy()
        let presenter = LoadResourcePresenter(loadingView: view, errorView: view)
        return (presenter, view)
    }
    
    class ViewSpy: ResourceLoadingView, ResourceErrorView {
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(errorMessage: String?)
        }
        var messages = [Message]()
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.errorMessage))
        }
    }
}
