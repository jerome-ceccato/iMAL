//
//  PeopleVoiceActingRoleTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 28/05/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class PeopleVoiceActingRoleTableViewCell: SelectableTableViewCell {
    @IBOutlet var animeImageView: UIImageView!
    @IBOutlet var animeTitleLabel: UILabel!
    
    @IBOutlet var characterImageView: UIImageView!
    @IBOutlet var characterNameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    
    @IBOutlet var separatorView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [animeImageView, characterImageView].compactMap({ $0 }).forEach { imageView in
            imageView.layer.cornerRadius = 3
            imageView.layer.masksToBounds = true
        }
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            [self.animeImageView, self.characterImageView].forEach { imageView in
                imageView?.backgroundColor = theme.entity.pictureBackground.color
            }
            self.animeTitleLabel.textColor = theme.genericView.importantText.color
            self.characterNameLabel.textColor = theme.genericView.importantText.color
            self.roleLabel.textColor = theme.genericView.subtitleText.color
            
            self.separatorView?.backgroundColor = theme.separators.heavy.color
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animeImageView.cancelImageLoading()
        characterImageView.cancelImageLoading()
    }

    func fill(with role: People.VoiceActingRole) {
        animeImageView.image = nil
        animeImageView.setImageWithURLString(role.anime.pictureURL)
        animeTitleLabel.text = role.anime.name

        characterImageView.image = nil
        characterImageView.setImageWithURLString(role.characterImageURL)
        characterNameLabel.text = role.characterName
        roleLabel.text = role.isMain ? "Main" : "Supporting"
    }
}
