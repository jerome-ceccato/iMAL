//
//  BrowseContentBaseTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 30/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseContentBaseTableViewCell: EntityOwnerTableViewCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var infosLabel: UILabel!
    
    @IBOutlet var myInfosView: UIView!
    @IBOutlet var myInfosHiddenConstraint: NSLayoutConstraint!
    
    @IBOutlet var myInfosStatus: UILabel!
    @IBOutlet var myInfosScore: UILabel!
    @IBOutlet var myInfosScoreIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.entity.name.color
            self.typeLabel.textColor = theme.entity.type.color
            self.infosLabel.textColor = theme.genericView.importantSubtitleText.color
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.cancelImageLoading()
    }
    
    func fill(with entity: Entity) {
        self.entity = entity
        
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(entity.pictureURL, animated: true, completion: nil)
        
        nameLabel.text = entity.name
        typeLabel.text = entity.type.displayString + (entity.classification.map { " | \($0)" } ?? "")
        
        if let anime = entity as? Anime {
            if anime.episodes > 0 {
                infosLabel.text = "\(anime.episodes) episode\(anime.episodes > 1 ? "s" : "")"
            }
            else {
                infosLabel.text = "? ep."
            }
            setupPersonalInfos(entity: CurrentUser.me.cachedAnimeList()?.find(by: anime.identifier))
        }
        else if let manga = entity as? Manga {
            infosLabel.text = MangaMetricsRepresentation.preferredMetricDisplayString(manga: manga)
            setupPersonalInfos(entity: CurrentUser.me.cachedMangaList()?.find(by: manga.identifier))
        }
    }
    
    private func setupPersonalInfos(entity: UserEntity?) {
        if let infos = entity {
            myInfosHiddenConstraint.priority = UILayoutPriority.defaultLow
            myInfosStatus.text = infos.specialStatus ?? infos.statusDisplayString
            myInfosScore.text = infos.score > 0 ? "\(infos.score)" : nil
            myInfosScoreIcon.isHidden = !(infos.score > 0)
            
            [myInfosScore, myInfosStatus].forEach { $0.textColor = infos.status.colorCode() }
            myInfosScoreIcon.tintColor = infos.status.colorCode()
        }
        else {
            myInfosHiddenConstraint.priority = UILayoutPriority.required - 1
        }
    }
}
