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
}

extension ManagedArtwork {
    static func find(in context: NSManagedObjectContext) throws -> ManagedArtworksCache? {
        let request = NSFetchRequest<ManagedArtworksCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete).map(context.save)
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedArtworksCache {
        try deleteCache(in: context)
        return ManagedArtworksCache(context: context)
    }
}
