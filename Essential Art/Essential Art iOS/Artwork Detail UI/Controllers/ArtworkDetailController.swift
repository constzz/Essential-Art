//
//  ArtworkDetailController.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import UIKit
import SwiftUI
import Essential_Art
import Combine

public final class ArtworkDetailController: ViewControllerWithStackInScroll {
    
    private enum Constants {
        static let stackViewInsets: UIEdgeInsets = .init(
            top: 12,
            left: 20,
            bottom: -12,
            right: -20)
        static let stackViewSpacing: CGFloat = 6
    }
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private(set) lazy var descrpitionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private(set) lazy var errorView = ErrorView()
    
    public private(set) lazy var imageController: ArtworkDetailImageController = {
        let controller = ArtworkDetailImageController()
        addChild(controller)
        controller.didMove(toParent: self)
        controller.view.constraint(height: 400)
        return controller
    }()
    
    public var onRefresh: (() -> Void)?
    
    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
        scrollView.refreshControl = makeRefreshControl()
        refresh()
    }
    
    @objc private func refresh() {
        onRefresh?()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        view.add(view: errorView, constraints: [
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        stackView.addArrangedSubview(imageController.view)
        stackView.addSpace(size: Constants.stackViewSpacing, axis: .vertical)
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpace(size: Constants.stackViewSpacing, axis: .vertical)
        stackView.addArrangedSubview(descrpitionLabel)
    }
    
    private func makeRefreshControl() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
        
}

extension ArtworkDetailController: ResourceView, ResourceErrorView, ResourceLoadingView {
    public typealias ResourceViewModel = ArtworkDetailViewModel
    
    public func display(_ viewModel: ResourceViewModel) {
        titleLabel.text = "\(viewModel.title) – \(viewModel.artist)"
        descrpitionLabel.text = viewModel.description
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        scrollView.refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.errorMessage
    }
}



