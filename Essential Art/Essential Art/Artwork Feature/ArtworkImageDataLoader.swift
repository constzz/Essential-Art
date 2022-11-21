//
//  ArtworkImageDataLoader.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 21.11.2022.
//

import Foundation

public protocol ArtworkImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
