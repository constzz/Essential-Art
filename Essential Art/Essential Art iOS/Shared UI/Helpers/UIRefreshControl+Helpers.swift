//
//  UIRefreshControl+Helpers.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
