//
//  SettingsTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 07/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class SettingsTableViewCell: SelectableTableViewCell {
    @IBOutlet var regularLabels: [UILabel]?
    @IBOutlet var subtitleLabels: [UILabel]?
    @IBOutlet var warningLabels: [UILabel]?
    @IBOutlet var imageViews: [UIImageView]?
    @IBOutlet var iconImageViews: [UIImageView]?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        applyTheme { [unowned self] theme in
            self.regularLabels?.forEach { label in
                label.textColor = theme.genericView.importantText.color
            }
            self.subtitleLabels?.forEach { label in
                label.textColor = theme.genericView.subtitleText.color
            }
            self.warningLabels?.forEach { label in
                label.textColor = theme.genericView.warningText.color
            }
            self.imageViews?.forEach { imageView in
                imageView.tintColor = theme.genericView.importantText.color
            }
            self.iconImageViews?.forEach { imageView in
                imageView.tintColor = theme.genericView.importantSubtitleText.color
            }
        }
    }
    
    override func themeCellForHighlight(_ highlighted: Bool) {
        let theme = ThemeManager.currentTheme.settings
        backgroundColor = highlighted ? theme.cellSelectedColor.color : theme.cellBackgroundColor.color
    }
}
