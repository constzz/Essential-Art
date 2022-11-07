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
    
    private struct ArtworkModel: Decodable {
        let id: UUID
        let title: String
        let artist: String
        private let config: Config
        
        var imageURL: URL? {
            return .init(string:
                config.iiifURL
                    .appending("\(id.uuidString)")
                    .appending("full/843,/0/default.jpg")
            )
        }
        
        var artwork: Artwork? {
            guard let imageURL = imageURL else { return nil }
            return Artwork(id: id, title: title, imageURL: imageURL, artist: artist)
        }
        
        private struct Config: Decodable {
            let iiifURL: String
            private enum CodingKeys: String, CodingKey {
                case iiifURL = "iiif_url"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case id, title, artist = "artist_display", config
        }
    }
    
    private init () {}
    
    private static let validResponseCode = 200

    public static func map(data: Data, response: HTTPURLResponse) throws -> [Artwork] {
        guard response.statusCode == validResponseCode,
                let artworks = try? JSONDecoder().decode([ArtworkModel].self, from: data) else {
            throw Error.invalidData
        }
        return artworks.compactMap { $0.artwork }
    }
}
