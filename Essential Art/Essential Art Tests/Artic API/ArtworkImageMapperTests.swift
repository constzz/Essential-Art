//
//  ArtworkImageMapperTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
import Essential_Art
import XCTest

class ArtworkImageMapperTests: XCTestCase {

    private var anyData = Data("any data".utf8)
    private var invalidImageData = Data()
    private var validImageData = Data("some data".utf8)
    
    func test_map_throwsErrorOnNon200ResponseStatusCode() throws {
        
        let non200StatusCodes = [199, 201, 203, 299, 301, 400]
        
        try non200StatusCodes.forEach { statusCode in
            XCTAssertThrowsError(
                try ArticImageDataMapper.map(anyData, from: HTTPURLResponse(statusCode: statusCode)),
                "Expected to throw on \(statusCode) status code."
            )
        }
    }
    
    func test_map_throwsErrorOnInvalidData() throws {
        let statusCode = 200
        XCTAssertThrowsError(
            try ArticImageDataMapper.map(invalidImageData, from: HTTPURLResponse(statusCode: statusCode)),
            "Expected to throw on \(statusCode) status code."
        )
    }
    
    func test_map_deliversImageAndResponse_on200ResponseStatusCodeAndValidDataImage() throws {
        let response = HTTPURLResponse(statusCode: 200)

        let (mappedData, mappedResponse) = try ArticImageDataMapper.map(validImageData, from: response)
        
        XCTAssertEqual(validImageData, mappedData)
        XCTAssertEqual(response, mappedResponse)
    }
    
}

