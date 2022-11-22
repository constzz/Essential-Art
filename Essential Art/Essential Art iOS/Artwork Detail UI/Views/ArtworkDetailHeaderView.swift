//
//  ArtworkDetailHeaderView.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import UIKit
import Essential_Art

public final class ArtworkDetailImageController: UIViewController, ResourceView, ResourceErrorView, ResourceLoadingView {
    
    private var header = ArtworkDetailHeaderView()
    
    public var delegate: ArtworksItemCellControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(header)
        header.pinToSuperView()
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
        print(viewModel.errorMessage)
    }
}

final class ArtworkDetailHeaderView: StretchyTableHeaderView {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemGray
        return imageView
    }()
    
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
        
        imageView.pinToSuperView()
    }
}
