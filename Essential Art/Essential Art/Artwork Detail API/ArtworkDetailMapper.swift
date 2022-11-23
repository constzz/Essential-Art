//
//  ArtworkDetailMapper.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation

public final class ArtworkDetailMapper {
    private init () {}

    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct ArtworkDetailRoot: Decodable {
        let data: ArtworkDetailModel
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
    
    private struct ArtworkDetailModel: Decodable {
        private struct Thumbnail: Decodable {
            let altText: String?
            private enum CodingKeys: String, CodingKey {
                case altText = "alt_text"
            }
        }
        let imageID: String
        let title: String
        let artist: String
        private let thumbnail: Thumbnail
        
        func artworkDetail(withBaseURL baseURL: URL) throws -> ArtworkDetail {
            
            let imageURL = baseURL
                .appendingPathComponent("/\(imageID)")
                .appendingPathComponent("/full/843,/0/default.jpg")
            
            return ArtworkDetail(
                title: title,
                artist: artist,
                description: thumbnail.altText,
                imageURL: imageURL)
        }
        
        private enum CodingKeys: String, CodingKey {
            case imageID = "image_id", title, artist = "artist_display", thumbnail
        }
    }
    
    private static let validResponseCode = 200
    
    public static func map(data: Data, response: HTTPURLResponse) throws -> ArtworkDetail {
        guard response.statusCode == validResponseCode,
              let artworkRoot = try? JSONDecoder().decode(ArtworkDetailRoot.self, from: data)
        else {
            throw Error.invalidData
        }
        
        return try artworkRoot.data.artworkDetail(withBaseURL: artworkRoot.baseURL)
    }

}
