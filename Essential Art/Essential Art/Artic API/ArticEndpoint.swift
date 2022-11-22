//
//  ArticEndpoint.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation

public enum ArticEndpoint {
    case get(page: Int?, limit: Int?)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(page, limit):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/api/v1/artworks"
            components.queryItems = [
                .init(name: "limit", value: String(limit ?? 10)),
                .init(name: "page", value: String(page ?? 0))
            ]
            return components.url!
        }
    }
}
