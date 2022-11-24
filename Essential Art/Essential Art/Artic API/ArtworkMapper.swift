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
		private let pagination: Pagination?

		private struct Pagination: Decodable {
			let totalPages: Int
			let currentPage: Int
			private enum CodingKeys: String, CodingKey {
				case totalPages = "total_pages", currentPage = "current_page"
			}
		}

		var baseURL: URL {
			config.iiifURL
		}

		var hasNext: Bool {
			guard let pagination = pagination else {
				return false
			}

			return pagination.currentPage < pagination.totalPages
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

	private init() {}

	private static let validResponseCode = 200

	public static func map(data: Data, response: HTTPURLResponse) throws -> (artworks: [Artwork], hasNext: Bool) {
		guard response.statusCode == validResponseCode,
		      let artworkRoot = try? JSONDecoder().decode(ArtworkRoot.self, from: data)
		else {
			throw Error.invalidData
		}
		let artworks = artworkRoot.data.compactMap { try? $0.artwork(withBaseURL: artworkRoot.baseURL) }
		return (artworks, artworkRoot.hasNext)
	}
}
