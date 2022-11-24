//
//  ArtworkDetailEndpoint.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation

public enum ArtworkDetailEndpoint {
	case get(id: Int)

	public func url(baseURL: URL) -> URL {
		switch self {
		case let .get(id):
			return baseURL.appendingPathComponent("api/v1/artworks/\(id)")
		}
	}
}
