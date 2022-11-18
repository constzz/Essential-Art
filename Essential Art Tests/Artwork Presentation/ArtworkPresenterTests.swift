//
//  ArtworkPresenterTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class ArtworkPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ArtworkPresenter.title, localized("ARTWORKS_VIEW_TITLE"))
    }
    
    func test_artworkItemRetryButton_isLocalized() {
        XCTAssertEqual(ArtworkPresenter.retryButtonTitle, localized("ARTWORKS_VIEW_RETRY_BUTTON_TITLE"))
    }
    
    // MARK: - Helpers
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Artworks"
        let bundle = Bundle(for: ArtworkPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
