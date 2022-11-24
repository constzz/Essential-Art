//
//  HTTPClient.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 05.11.2022.
//

import Foundation

public protocol HTTPClientTask {
	func cancel()
}

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

	@discardableResult
	func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
