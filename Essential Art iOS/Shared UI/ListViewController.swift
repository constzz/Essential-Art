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



public class ListViewController: UITableViewController, ResourceLoadingView, ResourceErrorView {
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { (tableView, index, controller) in
            controller.dataSource.tableView(tableView, cellForRowAt: index)
        }
    }()
    
    private(set) lazy var errorView = ErrorView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        view.add(view: errorView, constraints: [
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        configureTableView()
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
    }
    
    public func display(_ sections: [CellController]...) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        sections.enumerated().forEach { section, cellControllers in
            snapshot.appendSections([section])
            snapshot.appendItems(cellControllers, toSection: section)
        }
        
        if #available(iOS 15.0, *) {
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            dataSource.apply(snapshot)
        }
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.errorMessage
    }
    
    
}
