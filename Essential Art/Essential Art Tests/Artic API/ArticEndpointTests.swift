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
        
        let sut = ArticEndpoint.get.url(baseURL: baseURL)
        
        XCTAssertEqual(sut.scheme, "http")
        XCTAssertEqual(sut.host, "base-url.com")
        XCTAssertEqual(sut.path, "/api/v1/artworks")
    }
}
