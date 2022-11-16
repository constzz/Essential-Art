//
//  ArtworkItemCellController.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 16.11.2022.
//

import UIKit
import Essential_Art

public protocol ArtworksItemCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class ArtworksItemCellController: NSObject {
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: ArworkItemViewModel
    private let delegate: ArtworksItemCellControllerDelegate
    private let selection: () -> Void
    private var cell: ArworkItemCell? {
        didSet {
            if let cell = cell {
                updateCell(cell, withViewModel: viewModel)
            }
        }
    }
        
    public init(viewModel: ArworkItemViewModel, delegate: ArtworksItemCellControllerDelegate, selection: @escaping () -> Void) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.selection = selection
    }
    
    private func updateCell(_ cell: ArworkItemCell, withViewModel viewModel: ArworkItemViewModel) {
        cell.artistLabel.text = viewModel.artist
        cell.titleLabel.text = viewModel.title
        
        cell.artworkImageView.image = nil
        cell.artworkImageView.isShimmering = true
        cell.artworkImageRetryButton.isHidden = true
        cell.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
        delegate.didRequestImage()
        
    }
}

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol InterfaceBuilderPrototypable {
    static var nib: UINib { get }
}

extension InterfaceBuilderPrototypable {
    static var nib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableView {
    // MARK: - UITableViewCell
    func register<T: UITableViewCell>(_: T.Type) where T: Reusable {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(_: T.Type) where T: Reusable, T: InterfaceBuilderPrototypable {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeue<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            abort()
        }
        return cell
    }
    
    // MARK: - UITableViewHeaderFooterView
    func register<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable, T: InterfaceBuilderPrototypable {
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeue<T: UITableViewHeaderFooterView>(_: T.Type) -> T where T: Reusable {
        guard let header = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            abort()
        }
        return header
    }
}


extension ArtworksItemCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cell = tableView.dequeue(ArworkItemCell.self, for: indexPath)
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension ArtworksItemCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: UIImage) {
        cell?.artworkImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.artworkImageView.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.artworkImageRetryButton.isHidden = viewModel.errorMessage == nil
    }
}
