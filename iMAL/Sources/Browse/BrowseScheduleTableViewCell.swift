//
//  BrowseScheduleTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseScheduleTableViewCell: EntityOwnerTableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genresLabel: UILabel!
    @IBOutlet var airingLabel: UILabel!
    
    @IBOutlet var pictureImageView: UIImageView!
    
    @IBOutlet var productionInfosLabel: UILabel!
    @IBOutlet var scoreInfosLabel: UILabel!
    @IBOutlet var membersInfosLabel: UILabel!
    @IBOutlet var scoreImageView: UIImageView!
    @IBOutlet var membersImageView: UIImageView!
    
    @IBOutlet var myInfosLabel: UILabel!
    @IBOutlet var myInfosContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [pictureImageView, myInfosContainerView.superview].compactMap({ $0 }).forEach { view in
            view.layer.cornerRadius = 3
            view.layer.masksToBounds = true
        }
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.entity.name.color
            [self.productionInfosLabel, self.genresLabel].forEach { label in
                label!.textColor = theme.entity.label.color
            }
            [self.scoreInfosLabel, self.membersInfosLabel].forEach { label in
                label!.textColor = theme.genericView.importantText.color
            }
            [self.scoreImageView, self.membersImageView].forEach { imageView in
                imageView?.tintColor = theme.genericView.importantText.color
            }
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.cancelImageLoading()
    }
    
    func fill(with anime: Anime, section: AnimeSchedule.Section) {
        self.entity = anime
        
        nameLabel.text = anime.name
        genresLabel.text = anime.genres.joined(separator: ", ")
        
        if let myInfos = CurrentUser.me.cachedAnimeList()?.find(by: anime.identifier) {
            myInfosLabel.text = myInfos.specialStatus ?? myInfos.statusDisplayString
            myInfosContainerView.backgroundColor = myInfos.status.colorCode()
            myInfosContainerView.isHidden = false
        }
        else {
            myInfosContainerView.isHidden = true
        }
        
        let theme = ThemeManager.currentTheme.genericView
        let content = NSMutableAttributedString()
        let regularAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: theme.importantSubtitleText.color]
        let highlightedAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: theme.importantText.color]
        let episodesAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: theme.highlightedText.color]
        
        let today = section.metadata.thisWeek ? Calendar.current.startOfDay(for: Date()) : Date()
        if Settings.airingDatesEnabled, let airingData = Database.shared.airingAnime?.findByID(anime.identifier), let nextEpisode = airingData.nextEpisode(after: today) {
            content.append(NSAttributedString(string: "ep. ", attributes: regularAttributes))
            content.append(NSAttributedString(string: "\(nextEpisode.number)", attributes: episodesAttributes))
            if anime.episodes > 0 {
                content.append(NSAttributedString(string: " / \(anime.episodes)", attributes: regularAttributes))
            }
            
            let displayTime = nextEpisode.airingTimeDisplayString(useDate: !section.metadata.thisWeek)
            content.append(NSAttributedString(string: " - ", attributes: regularAttributes))
            content.append(NSAttributedString(string: "\(displayTime)", attributes: highlightedAttributes))
        }
        else if anime.episodes > 0 {
            content.append(NSAttributedString(string: "\(anime.episodes)", attributes: highlightedAttributes))
            content.append(NSAttributedString(string: " ep\(anime.episodes > 1 ? "s" : "").", attributes: regularAttributes))
        }
        
        airingLabel.attributedText = content
        
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(anime.pictureURL, animated: true, completion: nil)

        productionInfosLabel.text = {
            let content: [String?] = [
                anime.producers.first,
                anime.type?.displayString
            ]
            
            return content.compactMap({ $0 }).joined(separator: " | ")
        }()
        
        scoreInfosLabel.text = anime.membersScore.flatMap({ $0 > Float.ulpOfOne ? $0 : nil }).map({ String(format: "%.2f", $0) }) ?? "?"
        membersInfosLabel.text = anime.membersCount.flatMap({ $0 > 0 ? $0 : nil }).map({ $0.formattedString }) ?? "?"
    }
}
