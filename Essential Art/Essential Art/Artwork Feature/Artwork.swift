//
//  Artwork.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation

public struct Artwork: Hashable {
    public let title: String
    public let imageURL: URL
    public let artist: String
    
    public init(
        title: String,
        imageURL: URL,
        artist: String
    ) {
        self.title = title
        self.imageURL = imageURL
        self.artist = artist

    }
}
