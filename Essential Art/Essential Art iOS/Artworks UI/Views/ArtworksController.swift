//
//  ArtworksController.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import Foundation

public class ArtworksController: ListViewController {

	public init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(ArworkItemCell.self)
	}
}
