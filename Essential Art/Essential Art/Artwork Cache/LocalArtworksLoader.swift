//
//  LocalArtworksLoader.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation

public class LocalArtworksLoader: ArtworksCache {
    private let store: ArtworksStore
    private let currentDate:  () -> Date
    
    public init(store: ArtworksStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load() throws -> [Artwork] {
        if let cache = try store.retrieve(), ArtworksCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.artworks
        }
        return []
    }
    
    public func save(_ artworks: [Artwork]) throws {
        try store.deleteCachedArtworks()
        try store.insert(artworks, timestamp: currentDate())
    }
    
    public func validateCache() throws {
        guard
            let cache = try? store.retrieve(),
            ArtworksCachePolicy.validate(cache.timestamp, against: currentDate())
        else {
            try store.deleteCachedArtworks()
            return
        }
    }
}
