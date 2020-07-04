//
//  EntityRelatedTableViewHeader.swift
//  iMAL
//
//  Created by Jerome Ceccato on 04/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class EntityRelatedTableViewHeader: ManagedTableViewHeader {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.titleLabel.textColor = theme.detailsView.relatedCategory.color
        }
    }
}
