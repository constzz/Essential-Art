//
//  ArtworksCachePolicy.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation

final class ArtworksCachePolicy {
	private init() {}

	private static let calendar = Calendar(identifier: .gregorian)

	private static var maxCacheAgeInDays: Int {
		return 14
	}

	static func validate(_ timestamp: Date, against date: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
			return false
		}
		return date < maxCacheAge
	}
}

private extension LocalArtwork {
	var model: Artwork {
		return Artwork(title: title, imageURL: imageURL, artist: artist, id: id)
	}
}
