//
//  ArtworksCache.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import Foundation

public protocol ArtworksCache {
    func save(_ artworks: [Artwork]) throws
}
