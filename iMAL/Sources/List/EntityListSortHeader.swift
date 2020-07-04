//
//  EntityListSortHeader.swift
//  iMAL
//
//  Created by Jerome Ceccato on 03/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class EntityListSortHeader: ManagedTableViewHeader {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.titleLabel.textColor = theme.dropdownPopup.sectionText.color
            self.contentBackgroundColor = theme.dropdownPopup.background.color
            self.contentView.backgroundColor = self.contentBackgroundColor
        }
    }
}
