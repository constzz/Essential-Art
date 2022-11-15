//
//  ListSnapshotTests.swift
//  Essential Art iOS Tests
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation
import UIKit
import XCTest
import Essential_Art_iOS

class ListSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display([])
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    private func makeSUT() -> ListViewController {
        let viewController = ListViewController()

        return viewController
    }
}
