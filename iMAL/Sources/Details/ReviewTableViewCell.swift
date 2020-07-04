//
//  ReviewTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/01/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class ReviewTableViewCell: SelectableTableViewCell {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var helpfulLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var snippetLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.avatarImageView.backgroundColor = theme.entity.pictureBackground.color
            self.usernameLabel.textColor = theme.genericView.importantText.color
            self.ratingLabel.textColor = theme.genericView.highlightedText.color
            self.subtitleLabel.textColor = theme.genericView.subtitleText.color

            self.snippetLabel.textColor = theme.genericView.htmlLongDescription.color
        }
    }
    
    func fill(with review: Review) {
        avatarImageView.image = nil
        if let url = review.avatarURL {
            avatarImageView.setImageWithURLString(url)
        }
        
        usernameLabel.text = review.username
        ratingLabel.text = "\(review.rating)"
        
        let theme = ThemeManager.currentTheme.genericView
        let helpfulContent = NSMutableAttributedString(string: "\(review.helpfulCount)", attributes: [NSAttributedStringKey.foregroundColor: theme.importantText.color])
        helpfulContent.append(NSAttributedString(string: " people found helpful", attributes: [NSAttributedStringKey.foregroundColor: theme.labelText.color]))
        helpfulLabel.attributedText = helpfulContent
        
        let secondaryInfos = [review.date?.shortDateDisplayString, review.mainMetricDisplayString].compactMap({ ($0?.isEmpty ?? true) ? nil : $0 })
        subtitleLabel.text = secondaryInfos.joined(separator: " | ")
        
        snippetLabel.text = review.reviewPlainText
    }
}
