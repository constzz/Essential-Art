//
//  ArtworkDetailHeaderView.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import UIKit
import Essential_Art

public final class ArtworkDetailImageController: UIViewController, ResourceView, ResourceErrorView, ResourceLoadingView {
    
    public private(set) var header = ArtworkDetailHeaderView()
    
    public var delegate: ArtworksItemCellControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(header)
        header.pinToSuperView()
        
        header.onRetry = delegate?.didRequestImage
    }
    
    deinit {
        delegate?.didCancelImageRequest()
    }

    public typealias ResourceViewModel = UIImage
    
    public func display(_ viewModel: ResourceViewModel) {
        header.imageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        header.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        header.retryButton.isHidden = viewModel.errorMessage == nil
    }
}

public final class ArtworkDetailHeaderView: StretchyTableHeaderView {
    
    public private(set) lazy var retryButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.setTitle(ArtworkPresenter.retryButtonTitle, for: .normal)
        return button
    }()
    
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemGray
        return imageView
    }()
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    var onRetry: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        contentView.addSubview(imageView)
        contentView.add(view: retryButton, constraints: [
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        imageView.pinToSuperView()
    }
}
