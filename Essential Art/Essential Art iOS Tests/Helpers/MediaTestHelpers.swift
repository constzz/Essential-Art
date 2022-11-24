//
//  MediaTestHelpers.swift
//  Essential Art iOS Tests
//
//  Created by Konstantin Bezzemelnyi on 24.11.2022.
//

import Foundation
import XCTest

extension XCTestCase {
	var architecturePhotoSample1: FileAndURL {
		return getFile("architecture-photo-sample-1", withExtension: "jpeg")!
	}

	var architecturePhotoSample2: FileAndURL {
		return getFile("architecture-photo-sample-2", withExtension: "jpeg")!
	}
}
