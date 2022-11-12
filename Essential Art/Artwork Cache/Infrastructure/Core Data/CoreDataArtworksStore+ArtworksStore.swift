//
//  CoreDataArtworksStore+ArtworksStore.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 12.11.2022.
//

import Foundation

extension CoreDataArtworksStore: ArtworksStore {
    public func insert(_ artworks: [Artwork], timestamp: Date) throws {
        
    }
    
    public func deleteCachedArtworks() throws {
        
    }
    
    public func retrieve() throws -> ArtworksCached? {
        return nil
    }
}
