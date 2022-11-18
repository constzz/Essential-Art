//
//  ArworkItemCell.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import UIKit
import Essential_Art

public class ArworkItemCell: UITableViewCell, Reusable {
    
    private enum Constants {
        static let verticalCellSpacing: CGFloat = 12
        static let horizontalCellSpacing: CGFloat = 20
        static let textToImageSpacing: CGFloat = 4
    }
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    lazy var artworkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var artworkImageViewContainer: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        view.heightAnchor.constraint(equalToConstant: 320).isActive = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .systemGray
        return view
    }()
    
    lazy var artworkImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.setTitle(ArtworkPresenter.retryButtonTitle, for: .normal)
        return button
    }()
    
    lazy var stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    var onRetry: (() -> Void)?
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
        
        addStackView(stackViewContainer)
        addSubviewsToStackView(stackViewContainer)
                
        addImageView(artworkImageView, inContainer: artworkImageViewContainer)
        addImageRetryView(artworkImageRetryButton, inContainer: artworkImageViewContainer)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI setup
private extension ArworkItemCell {
    func addStackView(_ stackView: UIStackView) {
        addSubview(stackViewContainer)
        stackViewContainer.pinToSuperView(top: Constants.verticalCellSpacing,
                                          left: Constants.horizontalCellSpacing,
                                          bottom: -Constants.verticalCellSpacing,
                                          right: -Constants.horizontalCellSpacing)
    }
    
    func addSubviewsToStackView(_ stackView: UIStackView) {
        stackViewContainer.addArrangedSubview(titleLabel)
        stackViewContainer.addSpace(size: Constants.textToImageSpacing, axis: .vertical)
        stackViewContainer.addArrangedSubview(artworkImageViewContainer)
        stackViewContainer.addSpace(size: Constants.textToImageSpacing, axis: .vertical)
        stackViewContainer.addArrangedSubview(artistLabel)
    }
    
    func addImageView(_ view: UIView, inContainer container: UIView) {
        artworkImageViewContainer.addSubview(artworkImageView)
        artworkImageView.pinTo(view: artworkImageViewContainer)
    }
    
    func addImageRetryView(_ view: UIView, inContainer container: UIView) {
        container.addSubview(view)
        view.prepareForAutoLayout()
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }

}
