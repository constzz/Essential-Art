//
//  UIIntegrationTestHelpers.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 23.11.2022.
//

import Foundation
import XCTest
import Essential_Art

extension XCTestCase {
	class DummyView: ResourceView {
		func display(_ viewModel: Any) {}
	}

	var loadError: String {
		LoadResourcePresenter<Any, DummyView>.loadError
	}
}
