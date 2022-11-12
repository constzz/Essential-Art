//
//  CoreDataArtworksStore+ArtworksStore.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 12.11.2022.
//

import Foundation

extension CoreDataArtworksStore: ArtworksStore {
    public func insert(_ artworks: [Artwork], timestamp: Date) throws {
        try performSync { context in
            Result {
                let cache = ManagedArtworksCache(context: context)
                context.userInfo.removeAllObjects()
                cache.artworks = NSOrderedSet(array: artworks.map { artwork in
                    let managed = ManagedArtwork(context: context)
                    managed.artist = artwork.artist
                    managed.imageURL = artwork.imageURL
                    managed.title = artwork.title
                    return managed
                })
                cache.timestamp = timestamp
                try context.save()
            }
        }
    }
    
    public func deleteCachedArtworks() throws {
        
    }
    
    public func retrieve() throws -> ArtworksCached? {
        try performSync { context in
            Result {
                if let managedArtwork = try ManagedArtworksCache.find(in: context) {
                    let artworks: [Artwork] = managedArtwork.artworks.compactMap {
                        guard let managedArtwork = ($0 as? ManagedArtwork) else { return nil }
                        return Artwork(title: managedArtwork.title,
                                       imageURL: managedArtwork.imageURL,
                                       artist: managedArtwork.artist)
                    }
                    return (artworks, managedArtwork.timestamp)
                }
                return nil
            }
            
        }
    }
}
