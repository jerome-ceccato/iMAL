//
//  RecommendationTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/02/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class RecommendationTableViewCell: SelectableTableViewCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var recommendationCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.titleLabel.textColor = theme.genericView.importantText.color
        }
    }
    
    func fill(with recommendation: Recommendation) {
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(recommendation.entity.entity.pictureURL)
        
        titleLabel.text = recommendation.entity.entity.name
        
        let theme = ThemeManager.currentTheme.genericView
        let content = NSMutableAttributedString(string: "Recommended by ", attributes: [NSAttributedStringKey.foregroundColor: theme.labelText.color])
        content.append(NSAttributedString(string: "\(recommendation.recommendations.count)", attributes: [NSAttributedStringKey.foregroundColor: theme.importantText.color]))
        content.append(NSAttributedString(string: " user\(recommendation.recommendations.count > 1 ? "s" : "")", attributes: [NSAttributedStringKey.foregroundColor: theme.labelText.color]))
        recommendationCountLabel.attributedText = content
    }
}
