//
//  ManagedArtwork.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 12.11.2022.
//

import Foundation
import CoreData

@objc(ManagedArtwork)
class ManagedArtwork: NSManagedObject {
    @NSManaged var artist: String
    @NSManaged var imageURL: URL
    @NSManaged var title: String
    @NSManaged var id: Int
}
