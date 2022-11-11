//
//  SharedTestHelpers.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation

let anyURL = URL(string: "http://any-url.com")!
let anyURL2 = URL(string: "http://another-url.com")!
let anyError = NSError(domain: "any-error", code: 0)

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
