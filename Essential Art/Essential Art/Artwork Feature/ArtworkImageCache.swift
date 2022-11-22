//
//  ArtworkImageCache.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import UIKit

public protocol ArtworkImageStore {
    func save(_ image: UIImage, for response: HTTPURLResponse) throws
    func retrieve(dataForURL url: URL) throws -> UIImage
}
