//
//  PeopleStaffPositionTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 28/05/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class PeopleStaffPositionTableViewCell: SelectableTableViewCell {
    @IBOutlet var entityImageView: UIImageView!
    @IBOutlet var entityNameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    
    @IBOutlet var separatorView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        entityImageView.layer.cornerRadius = 3
        entityImageView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.entityImageView.backgroundColor = theme.entity.pictureBackground.color
            self.entityNameLabel.textColor = theme.genericView.importantText.color
            self.roleLabel.textColor = theme.genericView.subtitleText.color
            
            self.separatorView?.backgroundColor = theme.separators.heavy.color
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        entityImageView.cancelImageLoading()
    }
    
    func fill(with position: People.StaffPosition) {
        entityImageView.image = nil
        entityImageView.setImageWithURLString(position.entity.pictureURL)
        
        entityNameLabel.text = position.entity.name
        roleLabel.text = position.position
    }
}
