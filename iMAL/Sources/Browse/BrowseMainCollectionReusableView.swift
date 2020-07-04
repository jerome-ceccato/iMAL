//
//  BrowseMainCollectionReusableView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseMainCollectionReusableView: UICollectionReusableView {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel?
    
    @IBOutlet var arrowImageView: UIImageView?
    
    private var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewPressed)))
        
        applyTheme { [unowned self] theme in
            self.iconImageView.tintColor = theme.genericView.importantText.color
            self.titleLabel.textColor = theme.genericView.importantText.color
            self.subtitleLabel?.textColor = theme.genericView.importantSubtitleText.color
            self.arrowImageView?.tintColor = theme.genericView.importantText.color
        }
    }
    
    func fill(with kind: EntityKind, action: @escaping () -> Void) {
        subtitleLabel?.text = subtitle(for: kind)
        self.action = action
    }
    
    @objc func viewPressed() {
        action?()
    }
    
    private func subtitle(for kind: EntityKind) -> String {
        switch kind {
        case .anime:
            return "Find by genre, aired dates, score, rating and more"
        case .manga:
            return "Find by genre, published dates, score, rating and more"
        }
    }
}
