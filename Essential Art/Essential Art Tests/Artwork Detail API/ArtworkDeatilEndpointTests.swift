//
//  ArtworkDeatilEndpointTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ArtworkDetailEndpointTests: XCTestCase {
    func test_artworkDetail_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        let imageID = "39393"
        
        let sut = ArtworkDetailEndpoint.get(id: imageID).url(baseURL: baseURL)
        
        XCTAssertEqual(sut.scheme, "http")
        XCTAssertEqual(sut.host, "base-url.com")
        XCTAssertEqual(sut.path, "/api/v1/artworks/\(imageID)")
    }
}
