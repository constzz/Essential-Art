//
//  NullStore.swift
//  Essential Art App
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import Essential_Art
import Foundation

class NullStore {}

extension NullStore: ArtworksStore {
	func insert(_ artworks: [Artwork], timestamp: Date) throws {}
	func deleteCachedArtworks() throws {}
	func retrieve() throws -> ArtworksCached? { .none }
}
