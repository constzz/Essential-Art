//
//  URLSessionHTTPClient.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 05.11.2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    struct UnexpectedValueRepresentation: Swift.Error {}
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            completion(.init(catching: {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValueRepresentation()
                }
            }))
        }
        
        task.resume()
    }
}
