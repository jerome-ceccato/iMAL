//
//  BrowseSearchMultipleSelectionTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 18/04/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseSearchMultipleSelectionTableViewCell: UITableViewCell {
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var selectedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        applyTheme { [unowned self] theme in
            self.selectedImageView.tintColor = theme.genericView.importantText.color
        }
    }
    
    func fill(with content: String, isSelected: Bool) {
        let theme = ThemeManager.currentTheme
        
        contentLabel.text = content
        selectedImageView.alpha = isSelected ? 1 : 0
        contentLabel.textColor = isSelected ? theme.genericView.importantText.color : theme.genericView.importantSubtitleText.color
    }
}
