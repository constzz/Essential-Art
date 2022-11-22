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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private lazy var descrpitionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var header: ArtworkDetailHeaderView = {
        let header = ArtworkDetailHeaderView(frame: .zero)
        header.constraint(height: 400)
        return header
    }()
    
    private let viewModel: ArtworkDetailViewModel
    
    public init(viewModel: ArtworkDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateView(viewModel: viewModel)
        
        addSubviews()
    }
    
    private func updateView(viewModel: ArtworkDetailViewModel) {
        titleLabel.text = "\(viewModel.title) – \(viewModel.artist)"
        descrpitionLabel.text = viewModel.description
    }
    
    private func addSubviews() {
        stackView.addArrangedSubview(header)
        stackView.addSpace(size: Constants.stackViewSpacing, axis: .vertical)
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpace(size: Constants.stackViewSpacing, axis: .vertical)
        stackView.addArrangedSubview(descrpitionLabel)
    }
        
}

extension ArtworkDetailController: ResourceView, ResourceErrorView, ResourceLoadingView {
    public typealias ResourceViewModel = UIImage
    
    public func display(_ viewModel: ResourceViewModel) {
        header.imageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
    }
}


