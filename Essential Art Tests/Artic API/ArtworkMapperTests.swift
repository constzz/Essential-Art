//
//  ArtworkMapperTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ArtworkMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200ResponseStatusCode() throws {
        let artworksJSON = makeArtworksJSON([], baseURL: anyURL)
        let non200StatusCodes = [199, 201, 203, 299, 301, 400]
        try non200StatusCodes.forEach { statusCode in
            XCTAssertThrowsError(
                try ArtworkMapper.map(data: artworksJSON, response: HTTPURLResponse(statusCode: statusCode)),
                "Expected to throw on \(statusCode) status code."
            )
        }
    }
    
    func test_map_throwsErrorOnInvalidData() throws {
        let invalidData = Data("invalid data".utf8)
        
        let non200StatusCodes = [199, 200, 201, 299, 301, 400, 502]
        try non200StatusCodes.forEach { statusCode in
            XCTAssertThrowsError(
                try ArtworkMapper.map(data: invalidData, response: HTTPURLResponse(statusCode: statusCode))
            )
        }
    }
    
    func test_map_deliversEmptyList_on200ResponseStatusCodeAndEmptyJSONlist() throws {
        let emptyJSON = makeArtworksJSON([], baseURL: anyURL)
        
        let artworks = try ArtworkMapper.map(data: emptyJSON, response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(artworks, [])
    }
    
    func test_map_deliversItems_on200ResponseStatusCodeAndItemsJSON() throws {
        let baseURL = anyURL
        let artwork1 = makeArtwork(
            id: UUID(),
            title: "Any title",
            baseURL: baseURL,
            urlSuffix: "full/843,/0/default.jpg",
            artist: "A famous one")
        
        let artwork2 = makeArtwork(
            id: UUID(),
            title: "The art of programming",
            baseURL: baseURL,
            urlSuffix: "full/843,/0/default.jpg",
            artist: "Unknown artist")
        
        let json = makeArtworksJSON([artwork1.json, artwork2.json], baseURL: baseURL)
        
        let mappedItems = try ArtworkMapper.map(data: json, response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual([artwork1.model, artwork2.model], mappedItems)
    }
    
    private func makeArtwork(
        id: UUID,
        title: String,
        baseURL: URL,
        urlSuffix: String,
        artist: String
    ) -> (model: Artwork, json: [String: Any]) {
        
        let json = [
            "id": id.uuidString,
            "artist_display": artist,
            "title": title
        ].compactMapValues({$0})
        
        let artwork = Artwork(
            id: id,
            title: title,
            imageURL: baseURL.appendingPathComponent(id.uuidString).appendingPathComponent(urlSuffix),
            artist: artist)
        
        return (artwork, json)
    }
    
    private func makeArtworksJSON(
        _ artworks: [[String: Any]],
        baseURL: URL
    ) -> Data {
        let json: [String: Any] = [
            "data": artworks,
            "config": [
                "iiif_url": baseURL.absoluteString
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

var anyURL = URL(string: "http://any-url.com")!
var anyURL2 = URL(string: "http://another-url.com")!

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
