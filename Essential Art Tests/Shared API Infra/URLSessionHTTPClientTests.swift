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
    
    private var anyURL = URL(string: "http://any-url.com")!
    
    private func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }
}

private class URLProtocolStub: URLProtocol {
    typealias RequestObserver = ((URLRequest) -> Void)
    
    struct Stub {
        let data: Data?
        let response: HTTPURLResponse?
        let error: Error?
        let observer: RequestObserver?
    }
    
    static var stub: Stub?
    
    static func stubRequestsWith(
        data: Data?,
        response: HTTPURLResponse?,
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
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        stub.observer?(request)
    }
}
