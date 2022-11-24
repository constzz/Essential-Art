//
//  UIView+TestHelpers.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import UIKit

extension UIView {
	func enforceLayoutCycle() {
		layoutIfNeeded()
		RunLoop.current.run(until: Date())
	}
}
