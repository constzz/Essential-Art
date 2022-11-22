//
//  ArticEndpointTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 06.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ArticEndpointTests: XCTestCase {
    func test_artic_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let sut = ArticEndpoint.get(page: nil, limit: nil).url(baseURL: baseURL)
        
        XCTAssertEqual(sut.scheme, "http")
        XCTAssertEqual(sut.host, "base-url.com")
        XCTAssertEqual(sut.path, "/api/v1/artworks")
    }
    
    func test_artic_endpointURLPagination() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = ArticEndpoint.get(page: 2, limit: 6).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/api/v1/artworks", "path")
        XCTAssertEqual(received.query?.contains("limit=6"), true, "limit query param")
        XCTAssertEqual(received.query?.contains("page=2"), true, "page query param")
        
    }
}
