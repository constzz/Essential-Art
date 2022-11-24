//
//  URLSessionHTTPClientTests.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 05.11.2022.
//

import Foundation
import XCTest
import Essential_Art

class URLSessionHTTPClientTests: XCTestCase {

	override func tearDown() {
		URLProtocolStub.stub = nil
	}

	func test_getFromURL_performsGETRequestFromURL() {
		let url = anyURL
		let exp = expectation(description: "Request is performed")

		URLProtocolStub.observeRequests { urlRequest in
			XCTAssertEqual(urlRequest.url, url)
			XCTAssertEqual(urlRequest.httpMethod, "GET")
			exp.fulfill()
		}

		makeSUT().get(from: url) { _ in }

		wait(for: [exp], timeout: 5.0)
	}

	func test_cancelGetFromURL_deliversErrorInResponse() {
		// TODO: Research changes for URLSesssion API in cancellation of requests. Need to find another solution to test whether task was cancelled, because current approach sometimes fails on CI
		//        let error = resultErrorFor(
		//            client: makeSUT(),
		//            data: anyData,
		//            response: httpURLResponse,
		//            error: nil,
		//            taskHandler: { task in
		//                task.cancel()
		//        })
//
		//        XCTAssertEqual((error as? NSError)?.code, URLError.cancelled.rawValue)
	}

	func test_getFromURL_failsOnRequestError() {
		let error = resultErrorFor(client: makeSUT(), data: nil, response: nil, error: anyError)
		XCTAssertNotNil(error)
	}

	func test_getFromURL_failsOnInvalidRepresentation() {
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nil, error: anyError))
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nonHTTPURLResponse, error: nil))
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nonHTTPURLResponse, error: anyError))
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: httpURLResponse, error: anyError))

		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: nonHTTPURLResponse, error: nil))
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: nonHTTPURLResponse, error: anyError))
		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: httpURLResponse, error: anyError))

		XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: nil, error: nil))
	}

	func test_getFromURL_succedsWithDataOnValidRequest() {
		let emptyData = Data()
		switch resultFor(client: makeSUT(), data: emptyData, response: successfulHTTPURLResponse, error: nil) {
		case .success((let data, let response)):
			XCTAssertEqual(data, emptyData)
			XCTAssertEqual(response.statusCode, successfulHTTPURLResponse?.statusCode)
			XCTAssertEqual(response.url, successfulHTTPURLResponse?.url)
		case .failure(let error):
			XCTFail("Expected success, but recieved \(error) instead.")
		}
	}

	func test_getFromURL_succedsWithEmptyDataOnValidRequestAndNilDataRecieved() {
		let emptyData = Data()

		switch resultFor(client: makeSUT(), data: nil, response: successfulHTTPURLResponse, error: nil) {
		case .success((let data, let response)):
			XCTAssertEqual(data, emptyData)
			XCTAssertEqual(response.statusCode, successfulHTTPURLResponse?.statusCode)
			XCTAssertEqual(response.url, successfulHTTPURLResponse?.url)
		case .failure(let error):
			XCTFail("Expected success, but recieved \(error) instead.")
		}
	}

	private var nonHTTPURLResponse = URLResponse()
	private var httpURLResponse = HTTPURLResponse()
	private lazy var successfulHTTPURLResponse = HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)
	private var anyData = Data("any data".utf8)

	private func makeSUT() -> HTTPClient {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolStub.self]
		let session = URLSession(configuration: configuration)

		let client = URLSessionHTTPClient(session: session)
		trackForMemoryLeaks(client)

		return client
	}

	private func resultErrorFor(
		client: HTTPClient,
		data: Data?,
		response: URLResponse?,
		error: Error?,
		taskHandler: ((HTTPClientTask) -> Void)? = nil,
		file: StaticString = #file,
		line: UInt = #line
	) -> Error? {
		switch resultFor(client: client, data: data, response: response, error: error, taskHandler: taskHandler) {
		case .success((let data, let response)):
			XCTFail("Expected failure, recieved \(data) and \(response) instead.")
			return nil
		case .failure(let error):
			return error
		}
	}

	private func resultFor(
		client: HTTPClient,
		data: Data?,
		response: URLResponse?,
		error: Error?,
		taskHandler: ((HTTPClientTask) -> Void)? = nil,
		file: StaticString = #file,
		line: UInt = #line
	) -> HTTPClient.Result {
		URLProtocolStub.stubRequestsWith(data: data, response: response, error: error)
		var result: HTTPClient.Result!
		let exp = expectation(description: "Wait for completion")
		let task = client.get(from: anyURL) { completionResult in
			result = completionResult
			exp.fulfill()
		}
		taskHandler?(task)

		wait(for: [exp], timeout: 10.0)

		return result
	}
}
