//
//  XCTestCase+ArtworkIntegrationTests.swift
//  Essential Art Cache Integration Tests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
import XCTest
import Essential_Art

protocol ArtworksCacheIntegrationTests {
	var testSpecificStoreURL: URL { get }
}

extension ArtworksCacheIntegrationTests where Self: XCTestCase {

	func save(_ artworks: [Artwork], with loader: LocalArtworksLoader, file: StaticString = #file, line: UInt = #line) {
		do {
			try loader.save(artworks)
		} catch {
			XCTFail("Expected to save artworks successfully, got error: \(error)", file: file, line: line)
		}
	}

	var cacheDirectory: URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}

	func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL)
	}
}
