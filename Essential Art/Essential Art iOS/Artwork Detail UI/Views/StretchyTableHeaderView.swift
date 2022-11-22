//
//  StretchyTableHeaderView.swift
//  Essential Art iOS
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import UIKit

class StretchyTableHeaderView: UIView {
    internal let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: contentView.superview!.topAnchor)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(contentView)
        
        contentView.pinToSuperView(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = min(scrollView.contentOffset.y, 0)
        if offset > -scrollView.safeAreaInsets.top {
            offset = -scrollView.safeAreaInsets.top
        }
        contentViewTopConstraint.constant = offset
    }
}

