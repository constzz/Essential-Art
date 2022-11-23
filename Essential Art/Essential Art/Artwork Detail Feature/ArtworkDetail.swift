//
//  ArtworkDetail.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation

public struct ArtworkDetail: Hashable {
    public let title: String
    public let artist: String
    public let description: String?
    public let imageURL: URL
    
    public init(
        title: String,
        artist: String,
        description: String?,
        imageURL: URL
    ) {
        self.title = title
        self.artist = artist
        self.description = description
        self.imageURL = imageURL
    }
}
