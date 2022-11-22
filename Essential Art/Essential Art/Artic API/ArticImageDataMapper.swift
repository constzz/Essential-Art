//
//  ArticImageDataMapper.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 10.11.2022.
//

import Foundation
import UIKit

public final class ArticImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> (image: UIImage, response: HTTPURLResponse) {
        guard response.statusCode == 200, !data.isEmpty, let image = UIImage(data: data) else {
            throw Error.invalidData
        }
        
        return (image, response)
    }
}

