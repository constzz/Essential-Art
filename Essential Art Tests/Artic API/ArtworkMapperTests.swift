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
        let artworksJSON = makeArtworksJSON([])
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
    
    private func makeArtworksJSON(
        _ artworks: [[String: Any]]
    ) -> Data {
        let json = ["data": artworks]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

var anyURL = URL(string: "http://any-url.com")!

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
