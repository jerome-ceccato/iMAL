//
//  FriendCompareTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendCompareTableViewCell: EntityOwnerTableViewCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var myScoreLabel: UILabel!
    @IBOutlet var theirScoreLabel: UILabel!
    @IBOutlet var differenceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.titleLabel.textColor = theme.genericView.importantSubtitleText.color
            [self.myScoreLabel, self.theirScoreLabel].forEach { label in
                label?.textColor = theme.genericView.importantText.color
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.cancelImageLoading()
    }
    
    func fill(with item: FriendCompareViewController.Section.ScoreEntity) {
        self.entity = item.entity
        
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(item.entity.pictureURL, animated: true, completion: nil)
        titleLabel.text = item.entity.name
        
        myScoreLabel.text = item.myScore > 0 ? "\(item.myScore)" : "-"
        theirScoreLabel.text = item.theirScore > 0 ? "\(item.theirScore)" : "-"

        let theme = ThemeManager.currentTheme
        differenceLabel.text = "-"
        differenceLabel.textColor = theme.genericView.importantText.color
        
        if item.myScore > 0 && item.theirScore > 0 {
            let diff = item.theirScore - item.myScore
            differenceLabel.text = diff == 0 ? "0" : String(format: "%+d", diff)
            
            if diff > 0 {
                differenceLabel.textColor = theme.misc.comparisonPositive.color
            }
            else if diff < 0 {
                differenceLabel.textColor = theme.misc.comparisonNegative.color
            }
        }
    }
}
