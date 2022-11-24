//
//  URLCacheArtworkImageStore+ArtworkImageStore.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import Foundation

public class URLCacheArtworkImageStore: ArtworkImageStore {

	private enum Error: Swift.Error {
		case incorrectResponse(String)
		case emptyCache
	}

	private let cache: URLCache

	public init(cache: URLCache) {
		self.cache = cache
	}

	public func save(_ imageData: Data, for response: HTTPURLResponse) throws {
		guard let url = response.url else {
			throw Error.incorrectResponse("Url must not be nil.")
		}

		let cachedResponse = CachedURLResponse(response: response, data: imageData)

		cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
	}

	public func retrieve(dataForURL url: URL) throws -> Data {
		guard let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)) else {
			throw Error.emptyCache
		}

		return cachedResponse.data
	}
}
