//
//  ArtworkImageCache.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import Foundation

public protocol ArtworkImageStore {
    func save(_ imageData: Data, for response: HTTPURLResponse) throws
    func retrieve(dataForURL url: URL) throws -> Data
}
