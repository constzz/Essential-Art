//
//  ArtworksStore.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation

public typealias ArtworksCached = (artworks: [Artwork], timestamp: Date)

public protocol ArtworksStore {
    func insert(_ artworks: [Artwork], timestamp: Date) throws
    func deleteCachedArtworks() throws
    func retrieve() throws -> ArtworksCached?
}
