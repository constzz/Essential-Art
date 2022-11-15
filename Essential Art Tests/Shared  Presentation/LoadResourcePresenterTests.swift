//
//  LoadResourcePresenterTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation
import XCTest

final class LoadResourcePresenter {
    
}

class LoadResourcePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    private func makeSUT() -> (LoadResourcePresenter, ViewSpy) {
        let presenter = LoadResourcePresenter()
        let view = ViewSpy()
        return (presenter, view)
    }
    
    class ViewSpy {
        enum Message {
        }
        var messages = [Message]()
    }
}
