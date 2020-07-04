//
//  EntityOwnerCollectionViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 15/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class EntityOwnerCollectionViewCell: UICollectionViewCell, EntityOwnerCell {
    var entity: Entity!
    
    weak var longPressDelegate: EntityCellLongPressDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.userDidLongPress(_:))))
    }
    
    @objc func userDidLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            longPressDelegate?.didLongPressCell(self)
        }
    }
}
