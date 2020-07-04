//
//  BrowseHeaderCollectionReusableView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var seeAllLabel: UILabel?
    @IBOutlet var arrowImageView: UIImageView?
    
    private var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewPressed)))
        
        applyTheme { [unowned self] theme in
            self.iconImageView.tintColor = theme.genericView.importantText.color
            self.titleLabel.textColor = theme.genericView.importantText.color
            self.seeAllLabel?.textColor = theme.genericView.importantText.color
            self.arrowImageView?.tintColor = theme.genericView.importantText.color
        }
    }
    
    func fill(with kind: BrowseData.Section.Kind, action: @escaping () -> Void) {
        iconImageView.image = icon(for: kind).withRenderingMode(.alwaysTemplate)
        titleLabel.text = title(for: kind)
        self.action = action
    }
    
    @objc func viewPressed() {
        action?()
    }
    
    private func icon(for kind: BrowseData.Section.Kind) -> UIImage {
        switch kind {
        case .schedule:
            return #imageLiteral(resourceName: "Home-Schedule")
        case .top:
            return #imageLiteral(resourceName: "Home-Top")
        case .popular:
            return #imageLiteral(resourceName: "Home-Favourites")
        case .upcoming:
            return #imageLiteral(resourceName: "Home-Upcoming")
        case .justAdded:
            return #imageLiteral(resourceName: "Home-New")
        }
    }
    
    private func title(for kind: BrowseData.Section.Kind) -> String {
        switch kind {
        case .schedule:
            return "Schedule"
        case .top:
            return "Top"
        case .popular:
            return "Popular"
        case .upcoming:
            return "Upcoming"
        case .justAdded:
            return "Just added"
        }
    }
}
