//
//  XCTestCase+MemoryLeakTracking.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 07.11.2022.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
