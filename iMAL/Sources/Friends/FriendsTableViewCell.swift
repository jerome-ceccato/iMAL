//
//  FriendsTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 11/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendsTableViewCell: SelectableTableViewCell {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.avatarImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.genericView.importantText.color
        }
    }
    
    func fill(with friend: Friend) {
        nameLabel.text = friend.name
        
        avatarImageView.image = nil
        if let url = friend.avatarURL {
            avatarImageView.setImageWithURLString(url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.cancelImageLoading()
    }
}
