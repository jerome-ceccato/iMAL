//
//  BrowseEntityCollectionViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseEntityCollectionViewCell: EntityOwnerCollectionViewCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    class func requiredSize() -> CGSize {
        let normalizedWidth = min(414, min(AppDelegate.shared.viewPortSize.width, AppDelegate.shared.viewPortSize.height) / UIScreen.main.scale) * UIScreen.main.scale
        let itemsPerScreen = UIDevice.current.isiPad() ? 5 : 3.2
        let cellWidth: CGFloat = normalizedWidth / CGFloat(itemsPerScreen)
        
        return CGSize(width: floor(cellWidth), height: floor(cellWidth * 84 / 60))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 6
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
        }
    }
    
    func fill(with entity: Entity) {
        self.entity = entity
        
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(entity.pictureURL, animated: true, completion: nil)

        nameLabel.text = entity.name
    }
}
