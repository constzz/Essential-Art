//
//  UITableView+Extensions.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 17.11.2022.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol InterfaceBuilderPrototypable {
    static var nib: UINib { get }
}

extension InterfaceBuilderPrototypable {
    static var nib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: Reusable {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(_: T.Type) where T: Reusable, T: InterfaceBuilderPrototypable {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeue<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            abort()
        }
        return cell
    }
}
