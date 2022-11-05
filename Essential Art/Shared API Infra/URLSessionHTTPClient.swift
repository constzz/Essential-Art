//
//  URLSessionHTTPClient.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 05.11.2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            
        }
        
        task.resume()
    }
}
