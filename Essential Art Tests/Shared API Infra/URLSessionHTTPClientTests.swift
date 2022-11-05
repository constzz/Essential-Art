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
    
    func test_getFromURL_failsOnRequestError() {
        let error = resultErrorFor(client: makeSUT(), data: nil, response: nil, error: anyError)
        XCTAssertNotNil(error)
    }
    
    func test_getFromURL_failsOnInvalidRepresentation() {
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: anyData, response: nonHTTPURLResponse, error: anyError))
        
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: httpURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: httpURLResponse, error: anyError))
        
        XCTAssertNotNil(resultErrorFor(client: makeSUT(), data: nil, response: nil, error: nil))
    }
    
    private var anyURL = URL(string: "http://any-url.com")!
    private var anyError = NSError(domain: "any-error", code: 0)
    private var nonHTTPURLResponse = URLResponse()
    private var httpURLResponse = HTTPURLResponse()
    private var anyData = Data("any data".utf8)
    
    private func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }
    
    private func resultErrorFor(
        client: HTTPClient,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        switch resultFor(client: client, data: data, response: response, error: error) {
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
        file: StaticString = #file,
        line: UInt = #line
    ) -> HTTPClient.Result {
        URLProtocolStub.stubRequestsWith(data: data, response: response, error: error)
        var result: HTTPClient.Result!
        let exp = expectation(description: "Wait for completion")
        client.get(from: anyURL) { completionResult in
            result = completionResult
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return result

    }
}

private class URLProtocolStub: URLProtocol {
    typealias RequestObserver = ((URLRequest) -> Void)
    
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let observer: RequestObserver?
    }
    
    static var stub: Stub?
    
    static func stubRequestsWith(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) {
        stub = .init(data: data, response: response, error: error, observer: nil)
    }
    
    static func observeRequests(_ requestObserver: @escaping RequestObserver) {
        stub = .init(data: nil, response: nil, error: nil, observer: requestObserver)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = Self.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        stub.observer?(request)
    }
    
    override func stopLoading() {
        
    }
}
