//
//  BrowseContentTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 14/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseContentTableViewCell: BrowseContentBaseTableViewCell {
    @IBOutlet var infosSubtitleLabel: UILabel!

    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var rankContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.infosSubtitleLabel.textColor = theme.genericView.importantSubtitleText.color
        }
    }
    
    func fill(with entity: Entity, contentKind: BrowseData.Section.Kind, indexPath: IndexPath) {
        fill(with: entity)
        
        let rankVisible = contentKind == .top || contentKind == .popular
        rankLabel.text = "#\(indexPath.row + 1)"
        rankContainerView.isHidden = !rankVisible

        infosSubtitleLabel.attributedText = NSAttributedString(string: "")
        let theme = ThemeManager.currentTheme
        switch contentKind {
        case .top:
            if let score = entity.membersScore.flatMap({ $0 > Float.ulpOfOne ? $0 : nil }) {
                let scoreAmount = String(format: "%.2f", score)
                let content = NSMutableAttributedString()
                content.append(NSAttributedString(string: "Score: ", attributes: [NSAttributedStringKey.foregroundColor: theme.genericView.importantSubtitleText.color]))
                content.append(NSAttributedString(string: scoreAmount, attributes: [NSAttributedStringKey.foregroundColor: theme.genericView.highlightedText.color]))
                infosSubtitleLabel.attributedText = content
            }
        case .popular:
            if let members = entity.membersCount.flatMap({ $0 > 0 ? $0 : nil }) {
                let membersAmount = members.formattedString
                let content = NSMutableAttributedString()
                content.append(NSAttributedString(string: "Members: ", attributes: [NSAttributedStringKey.foregroundColor: theme.genericView.importantSubtitleText.color]))
                content.append(NSAttributedString(string: membersAmount, attributes: [NSAttributedStringKey.foregroundColor: theme.genericView.highlightedText.color]))
                infosSubtitleLabel.attributedText = content
            }
        default:
            infosSubtitleLabel.text = entity.classification
        }
    }
}
