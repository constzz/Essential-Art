//
//  URLCacheArtworkImageStore+ArtworkImageStore.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import Foundation
import UIKit

public class URLCacheArtworkImageStore: ArtworkImageStore {
    
    private enum Error: Swift.Error {
        case incorrectResponse(String)
        case invalidImageRepresentation
        case emptyCache
    }
    
    private let cache: URLCache
    
    public init(cache: URLCache) {
        self.cache = cache
    }
    
    public func save(_ image: UIImage, for response: HTTPURLResponse) throws {
        guard let url = response.url else {
            throw Error.incorrectResponse("Url must not be nil.")
        }
        guard let data = image.pngData() else {
            throw Error.invalidImageRepresentation
        }
        
        let cachedResponse = CachedURLResponse(response: response, data: data)
        
        cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
    }
    
    public func retrieve(dataForURL url: URL) throws -> UIImage {
        guard let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)) else {
            throw Error.emptyCache
        }
        
        guard let image = UIImage(data: cachedResponse.data) else {
            throw Error.invalidImageRepresentation
        }
        
        return image
    }
}
    
