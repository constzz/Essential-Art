//
//  ResourceErrroView.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation

public struct ResourceErrorViewModel {
	public let errorMessage: String?
	public static let noError = ResourceErrorViewModel(errorMessage: nil)
}

public protocol ResourceErrorView {
	func display(_ viewModel: ResourceErrorViewModel)
}
