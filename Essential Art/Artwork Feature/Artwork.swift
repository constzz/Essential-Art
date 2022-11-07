//
//  Artwork.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation

public struct Artwork: Equatable {
    let id: UUID
    let title: String
    let imageURL: URL
    let artist: String
    
    public init(
        id: UUID,
        title: String,
        imageURL: URL,
        artist: String
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.artist = artist

    }
}
