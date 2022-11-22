//
//  ArtworkDetailItemPresenter.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation

public final class ArtworkDetailPresenter {
    private init () {}

    public static func map(_ artworkDetail: ArtworkDetail) -> ArtworkDetailViewModel {
        ArtworkDetailViewModel(title: artworkDetail.title, artist: artworkDetail.artist, description: artworkDetail.description)
    }
}
