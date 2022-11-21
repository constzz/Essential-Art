//
//  ArtworkImagePresenter.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import Foundation

public final class ArtworkImagePresenter {
    public static func map(_ artwork: Artwork) -> ArtworkItemViewModel {
        ArtworkItemViewModel(title: artwork.title, artist: artwork.artist)
    }
}
