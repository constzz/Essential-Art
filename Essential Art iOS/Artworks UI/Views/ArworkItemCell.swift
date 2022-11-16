//
//  ArworkItemCell.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import UIKit

public class ArworkItemCell: UITableViewCell, Reusable {
    
    private enum Constants {
        static let verticalCellSpacing: CGFloat = 12
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
    
    lazy var artworkImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
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
        addSubview(stackViewContainer)
        stackViewContainer.pinToSuperView(top: Constants.verticalCellSpacing,
                                          bottom: -Constants.verticalCellSpacing)
        
        stackViewContainer.addArrangedSubview(titleLabel)
        stackViewContainer.addSpace(size: Constants.textToImageSpacing, axis: .vertical)
        stackViewContainer.addArrangedSubview(artworkImageView)
        stackViewContainer.addSpace(size: Constants.textToImageSpacing, axis: .vertical)
        stackViewContainer.addArrangedSubview(artistLabel)
        
        artworkImageView.prepareForAutoLayout()
        artworkImageView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        artworkImageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
