//
//  Files+TestHelpers.swift
//  Essential Art iOS Tests
//
//  Created by Konstantin Bezzemelnyi on 24.11.2022.
//

import Foundation
import XCTest

extension XCTestCase {
	typealias FileAndURL = (data: Data, url: URL)
	func getFile(_ name: String, withExtension: String) -> FileAndURL? {
		guard let url = Bundle(for: Self.self)
			.url(forResource: name, withExtension: withExtension) else { return nil }
		guard let data = try? Data(contentsOf: url) else { return nil }
		return (data, url)
	}
}
