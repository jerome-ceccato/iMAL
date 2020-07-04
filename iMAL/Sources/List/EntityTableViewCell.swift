//
//  EntityTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityTableViewCell: EntityOwnerTableViewCell, EntityCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    var canDisplayEditingControls: Bool {
        return false
    }
    
    private(set) var userEntity: UserEntity?
    private(set) var metadata: EntityCellMetadata?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.entity.name.color
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.cancelImageLoading()
    }

    private func fill(withEntity entity: Entity, metadata: EntityCellMetadata? = nil) {
        self.entity = entity

        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(entity.pictureURL, animated: true, completion: nil)
        
        if let metadata = metadata, let _ = metadata.highlightedText {
            nameLabel.attributedText = metadata.attributedString(withHighlightableContent: entity.name)
        }
        else {
            nameLabel.text = entity.name
        }
    }
    
    func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        userEntity = entity
        
        fill(withEntity: entity.series, metadata: metadata)
        scoreLabel.attributedText = UserEntityAttributedRepresentation.attributedDisplayString(forScore: entity.score)
        
        statusLabel.attributedText = UserEntityStatusRepresentation.fullStatusAttributedDisplayString(for: entity, metadata: metadata)
    }
}
