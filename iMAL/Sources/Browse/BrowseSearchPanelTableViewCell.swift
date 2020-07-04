//
//  BrowseSearchPanelTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 06/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class BrowseSearchPanelTableViewCell: SelectableTableViewCell {
    @IBOutlet var mainLabel: UILabel?
    @IBOutlet var textField: UITextField?
    @IBOutlet var buttonLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        applyTheme { [unowned self] theme in
            self.mainLabel?.textColor = theme.genericView.importantText.color
            self.textField?.textColor = theme.genericView.highlightedText.color
            self.buttonLabel?.textColor = theme.global.actionButton.color
        }
    }

    override func themeCellForHighlight(_ highlighted: Bool) {
        let theme = ThemeManager.currentTheme
        backgroundColor = highlighted ? theme.settings.cellSelectedColor.color : theme.settings.cellBackgroundColor.color
    }
}
