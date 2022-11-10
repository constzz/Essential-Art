//
//  ArticImageDataMapper.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 10.11.2022.
//

import Foundation

public final class ArticImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.statusCode == 200, !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
}

