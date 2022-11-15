//
//  ArtworkPresenter.swift
//  Essential Art
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation
public final class ArtworkPresenter {
    private init () {}

    public static let title: String = NSLocalizedString(
        "ARTWORKS_VIEW_TITLE",
        tableName: "Artworks",
        bundle: Bundle(for: ArtworkPresenter.self),
        comment: "Title for artworks view"
    )
}
