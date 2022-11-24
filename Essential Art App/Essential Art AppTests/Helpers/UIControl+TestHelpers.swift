//
//  UIControl+TestHelpers.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import UIKit

extension UIControl {
	func simulate(event: UIControl.Event) {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: event)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}
