//
//  ArworkItemViewModel.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import Foundation

public struct ArworkItemViewModel {
    public let title: String
    public let artist: String
    
    public init(
        title: String,
        artist: String
    ) {
        self.title = title
        self.artist = artist
    }
}
