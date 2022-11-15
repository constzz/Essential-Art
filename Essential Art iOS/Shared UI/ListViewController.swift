//
//  ListViewController.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 15.11.2022.
//

import Foundation
import UIKit
import Essential_Art

public struct CellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


public final class ListViewController: UITableViewController, ResourceLoadingView, ResourceErrorView {
    
    
    public func display(_ cellControllers: [CellController]) {
        
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        
    }
    
    
}
