//
//  RecommendationContentTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/02/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class RecommendationContentTableViewCell: SelectableTableViewCell {
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.contentLabel.textColor = theme.genericView.htmlLongDescription.color
        }
    }

    func fill(with recommendation: (user: String, content: String)) {
        contentLabel.text = recommendation.content
        
        let theme = ThemeManager.currentTheme.genericView
        let content = NSMutableAttributedString(string: "Recommended by ", attributes: [NSAttributedStringKey.foregroundColor: theme.labelText.color])
        content.append(NSAttributedString(string: recommendation.user, attributes: [NSAttributedStringKey.foregroundColor: theme.importantText.color]))
        userLabel.attributedText = content
    }
}
