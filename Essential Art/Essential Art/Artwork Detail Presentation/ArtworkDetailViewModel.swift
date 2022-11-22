//
//  ArtworkDetailItemViewModel.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation

public struct ArtworkDetailViewModel {
    public let title: String
    public let artist: String
    public let description: String?
    
    public init(
        title: String,
        artist: String,
        description: String?
    ) {
        self.title = title
        self.artist = artist
        self.description = description
    }
}
