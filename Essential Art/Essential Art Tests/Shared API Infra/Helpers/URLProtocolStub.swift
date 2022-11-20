//
//  URLProtocolStub.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 05.11.2022.
//

import Foundation

class URLProtocolStub: URLProtocol {
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
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub.observer?(request)
    }
    
    override func stopLoading() {
        
    }
}
