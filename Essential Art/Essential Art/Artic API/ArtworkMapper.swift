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
    
    private struct ArtworkRoot: Decodable {
        let data: [ArtworkModel]
        private let config: Config
        
        var baseURL: URL {
            config.iiifURL
        }
        
        private struct Config: Decodable {
            let iiifURL: URL
            private enum CodingKeys: String, CodingKey {
                case iiifURL = "iiif_url"
            }
        }
    }
    
    private struct ArtworkModel: Decodable {
        let id: Int
        let imageID: String?
        let title: String
        let artist: String
        
        func artwork(withBaseURL baseURL: URL) throws -> Artwork {
            guard let imageID = imageID else {
                throw Error.invalidData
            }
            
            let imageURL = baseURL
                .appendingPathComponent("/\(imageID)")
                .appendingPathComponent("/full/843,/0/default.jpg")

            return Artwork(title: title, imageURL: imageURL, artist: artist, id: id)
        }
        
        private enum CodingKeys: String, CodingKey {
            case imageID = "image_id", title, artist = "artist_display", id
        }
    }
    
    private init () {}
    
    private static let validResponseCode = 200

    public static func map(data: Data, response: HTTPURLResponse) throws -> [Artwork] {
        guard response.statusCode == validResponseCode,
              let artworkRoot = try? JSONDecoder().decode(ArtworkRoot.self, from: data)
        else {
            throw Error.invalidData
        }
        return artworkRoot.data.compactMap { try? $0.artwork(withBaseURL: artworkRoot.baseURL) }
    }
}
