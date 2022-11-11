//
//  ArtworksCacheHelpers.swift
//  Essential Art Tests
//
//  Created by Konstantin Bezzemelnyi on 11.11.2022.
//

import Foundation
import Essential_Art

func uniqueArtwork() -> Artwork {
    return Artwork(title: "any", imageURL: anyURL, artist: "any")
}

func uniqueArtworks() -> (models: [Artwork], localItems: [LocalArtwork]) {
    let models = [uniqueArtwork(), uniqueArtwork()]
    return (models, models.map { LocalArtwork(title: $0.title, imageURL: $0.imageURL, artist: $0.artist) })
}
