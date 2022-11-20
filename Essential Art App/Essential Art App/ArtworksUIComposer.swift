//
//  ArtworksUIComposer.swift
//  Essential Art App
//
//  Created by Konstantin Bezzemelnyi on 20.11.2022.
//

import Foundation
import Essential_Art
import Essential_Art_iOS

public final class ArtworksUIComposer {
    private init () {}
    
    public static func artworksComposedWith() -> ListViewController {
        let viewController = makeArtworksViewController(title: ArtworkPresenter.title)
        
        return viewController
    }

    private static func makeArtworksViewController(title: String) -> ListViewController {
        let viewController = ArtworksController() as ListViewController
        viewController.title = title
        return viewController
    }
    
}
