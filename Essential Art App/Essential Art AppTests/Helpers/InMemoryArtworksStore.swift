//
//  InMemoryArtworksStore.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 23.11.2022.
//

import Foundation
import Essential_Art

class InMemoryArtworksStore {
	typealias CachedArtwork = (artworks: [Artwork], timestamp: Date)
	private(set) var artworksCache: CachedArtwork?
	private var artworksImagesDataCache: [URL: Data] = [:]

	private init(artworksCache: CachedArtwork? = nil) {
		self.artworksCache = artworksCache
	}
}

extension InMemoryArtworksStore: ArtworksStore {
	func insert(_ artworks: [Artwork], timestamp: Date) throws {
		artworksCache = (artworks, timestamp)
	}

	func retrieve() throws -> ArtworksCached? {
		artworksCache
	}

	func deleteCachedArtworks() throws {
		artworksCache = nil
	}
}

extension InMemoryArtworksStore: ArtworkImageStore {
	func save(_ imageData: Data, for response: HTTPURLResponse) throws {
		artworksImagesDataCache[response.url!] = imageData
	}

	func retrieve(dataForURL url: URL) throws -> Data {
		guard let data = artworksImagesDataCache[url] else { throw NSError(domain: "not found", code: 0) }
		return data
	}
}

extension InMemoryArtworksStore {
	static var empty: InMemoryArtworksStore {
		InMemoryArtworksStore()
	}

	static var withExpiredFeedCache: InMemoryArtworksStore {
		InMemoryArtworksStore(artworksCache: ([], timestamp: Date.distantPast))
	}

	static var withNonExpiredFeedCache: InMemoryArtworksStore {
		InMemoryArtworksStore(artworksCache: ([], timestamp: Date()))
	}
}
