//
//  EntityCollectionViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCollectionViewCell: EntityOwnerCollectionViewCell, EntityCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    var canDisplayEditingControls: Bool {
        return false
    }
    
    private(set) var userEntity: UserEntity?
    private(set) var metadata: EntityCellMetadata?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 3
        containerView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.cancelImageLoading()
    }
    
    private func fill(withEntity entity: Entity, metadata: EntityCellMetadata? = nil) {
        self.entity = entity
        self.metadata = metadata
        
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(entity.pictureURL, animated: true, completion: nil)
    }
    
    func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        userEntity = entity
        
        fill(withEntity: entity.series, metadata: metadata)
    }
}
