//
//  AiringNotificationsAnimeTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class AiringNotificationsAnimeTableViewCell: UITableViewCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var enabledImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        let checkImage = #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
        enabledImageView.image = checkImage
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.entity.name.color
            self.statusLabel.textColor = theme.entity.status.color
            self.enabledImageView.tintColor = theme.genericView.importantText.color
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.cancelImageLoading()
    }
    
    func fill(with anime: UserAnime, enabled: Bool) {
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(anime.animeSeries.pictureURL, animated: true, completion: nil)
        
        nameLabel.text = anime.animeSeries.name
        statusLabel.text = anime.specialStatus ?? anime.statusDisplayString
        statusLabel.textColor = anime.status.colorCode()
        
        enabledImageView.alpha = enabled ? 1 : 0
    }
}
