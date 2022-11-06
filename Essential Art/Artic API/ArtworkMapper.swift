//
//  ArtworkMapper.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation

public final class ArtworkMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private init () {}
    
    private static let validResponseCode = 200

    public static func map(data: Data, response: HTTPURLResponse) throws -> [Artwork] {
        guard response.statusCode == validResponseCode else {
            throw Error.invalidData
        }
        return []
    }
}
