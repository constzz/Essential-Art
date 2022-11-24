//
//  SceneDelegateTests.swift
//  Essential Art AppTests
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import Foundation
import XCTest
import Essential_Art_iOS
@testable import Essential_Art_App

class SceneDelegateTests: XCTestCase {
	func test_configureWindow_setsWindowAsKeyAndVisible() {
		let window = UIWindowSpy()
		let sut = SceneDelegate()
		sut.window = window

		sut.configureWindow()

		XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
	}

	func test_configureWindow_configuresRootViewController() {
		let sut = SceneDelegate()
		sut.window = UIWindowSpy()

		sut.configureWindow()

		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let topController = rootNavigation?.topViewController

		XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is ArtworksController, "Expected a artworks controller as top view controller, got \(String(describing: topController)) instead")
	}

	private class UIWindowSpy: UIWindow {
		var makeKeyAndVisibleCallCount = 0

		override func makeKeyAndVisible() {
			makeKeyAndVisibleCallCount = 1
		}
	}
}
