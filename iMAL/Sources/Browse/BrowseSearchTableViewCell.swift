//
//  BrowseSearchTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 30/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseSearchTableViewCell: BrowseContentBaseTableViewCell {
    @IBOutlet var scoreLabel: UILabel!
    
    override func fill(with entity: Entity) {
        super.fill(with: entity)
        scoreLabel.attributedText = attributedStringForScore(entity: entity)
    }
    
    private func attributedStringForScore(entity: Entity) -> NSAttributedString? {
        if let score = entity.membersScore.flatMap({ $0 > Float.ulpOfOne ? $0 : nil }) {
            let theme = ThemeManager.currentTheme
            let scoreAmount = String(format: "%.2f", score)
            let content = NSMutableAttributedString()
            content.append(NSAttributedString(string: "Score: ", attributes: [NSAttributedStringKey.foregroundColor: theme.genericView.importantSubtitleText.color]))
            content.append(NSAttributedString(string: scoreAmount, attributes: [NSAttributedStringKey.foregroundColor: theme.genericView.highlightedText.color]))
            return content
        }
        return nil
    }
}
