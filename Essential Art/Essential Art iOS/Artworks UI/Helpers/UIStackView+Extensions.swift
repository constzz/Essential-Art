//
//  UIStackView+Extensions.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import UIKit

extension UIStackView {

	func addSpace(size: CGFloat, axis: NSLayoutConstraint.Axis) {
		let view = UIView()
		view.backgroundColor = .clear

		switch axis {
		case .horizontal:
			view.widthAnchor.constraint(equalToConstant: size).isActive = true
		case .vertical:
			view.heightAnchor.constraint(equalToConstant: size).isActive = true
		@unknown default: break
		}

		addArrangedSubview(view)
	}
}
