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
        
        switch resultFor(client: makeSUT(), data: nil, response: nil, error: anyError) {
        case .success((let data, let response)):
            XCTFail("Expected failure, recieved \(data) and \(response) instead.")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    private var anyURL = URL(string: "http://any-url.com")!
    private var anyError = NSError(domain: "any-error", code: 0)
    
    private func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }
    
    private func resultFor(
        client: HTTPClient,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> HTTPClient.Result {
        URLProtocolStub.stubRequestsWith(data: data, response: response, error: anyError)
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
