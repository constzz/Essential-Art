//
//  ResourceLoadingView.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}
