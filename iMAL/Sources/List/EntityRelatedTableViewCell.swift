//
//  EntityRelatedTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityRelatedTableViewCell: SelectableTableViewCell, ManagedTableViewCell {
    @IBOutlet var nameLabel: UILabel!
    
    static let requiredCellHeight: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.nameLabel.textColor = theme.global.link.color
        }
    }

    func fill(with data: Any, context: ManagedTableView.Context) {
        if let entity = data as? RelatedEntity {
            nameLabel.text = entity.name
        }
    }
}
