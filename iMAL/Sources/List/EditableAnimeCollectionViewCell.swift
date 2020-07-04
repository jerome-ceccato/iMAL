//
//  EditableAnimeCollectionViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EditableAnimeCollectionViewCell: AnimeCollectionViewCell, EditableAnimeCellActions {
    weak var delegate: EditableAnimeActionDelegate?

    @IBOutlet var bottomContainerView: UIView!
    
    @IBOutlet var episodesLabel: UILabel!
    
    @IBOutlet var rightLabel: UILabel!
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var scoreImageView: UIImageView!
    @IBOutlet var scoreContainerView: RoundCornersView!
    
    @IBOutlet var addEpisodesButtonContainerView: UIView!
    @IBOutlet var addEpisodesButton: UIButton!
    @IBOutlet var addEpisodesOverlayButton: UIButton?
    
    @IBOutlet var topContainerView: RoundCornersView!
    @IBOutlet var statusLabel: UILabel!
    
    var changes: AnimeChanges!
    var addTimer: Timer?
    
    override var canDisplayEditingControls: Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
                        
        topContainerView.corners = .bottomLeft
        scoreContainerView.corners = .topLeft
        
        applyTheme { [unowned self] theme in
            [self.bottomContainerView!,
             self.scoreContainerView!,
             self.addEpisodesButtonContainerView!].forEach { container in
                container.backgroundColor = theme.entity.cardsInfoBackground.color
            }
            self.topContainerView.backgroundColor = theme.entity.cardsInfoOverlayBackground.color
            
            self.scoreLabel.textColor = theme.entity.score.color
            self.scoreImageView.tintColor = theme.entity.score.color
        }
    }
    
    override func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        super.fill(withUserEntity: entity, metadata: metadata)
        
        if let anime = entity as? UserAnime {
            let theme = ThemeManager.currentTheme
            
            changes = AnimeChanges(anime: anime)
            
            let hasAddEpisodeButton = anime.sortingStatus == .watching
            
            addEpisodesButtonContainerView.isHidden = !hasAddEpisodeButton
            addEpisodesOverlayButton?.isHidden = addEpisodesButtonContainerView.isHidden
            
            addEpisodesButton.isEnabled = !addEpisodesButtonContainerView.isHidden
            addEpisodesOverlayButton?.isEnabled = addEpisodesButton.isEnabled
            
            if anime.status == .completed && !anime.restarting {
                episodesLabel.attributedText = UserEntityAttributedRepresentation.attributedCounter(withCurrent: anime.animeSeries.episodes, total: 0, suffix: " ep.")
            }
            else {
                episodesLabel.attributedText = UserAnimeRepresentation.attributedEpisodesCounter(for: anime)
            }
            
            if hasAddEpisodeButton {
                scoreContainerView.isHidden = true
            }
            else {
                scoreLabel.text = "\(anime.score)"
                scoreContainerView.isHidden = anime.score < 1
            }
            
            if metadata?.wantsFullStatus ?? false {
                statusLabel.attributedText = NSAttributedString(string: anime.specialStatus ?? anime.statusDisplayString, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                topContainerView.backgroundColor = anime.status.colorCode()
                topContainerView.isHidden = false
            }
            else {
                topContainerView.isHidden = true
            }
            
            if Settings.airingDatesEnabled, let data = Database.shared.airingAnime?.findByID(anime.series.identifier), let nextEpisode = data.nextEpisode() {
                if let metadata = metadata, metadata.style == .collectionViewSmall {
                    if nextEpisode.number == 1 {
                        rightLabel.attributedText = NSAttributedString(string: "\(nextEpisode.localTimeDisplayString())", attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.regular.color])
                    }
                    else if anime.watchedEpisodes + 1 >= nextEpisode.number {
                        rightLabel.attributedText = NSAttributedString(string: "\(nextEpisode.localTimeDisplayString())", attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.upToDate.color])
                    }
                    else {
                        rightLabel.attributedText = NSAttributedString(string: "\(nextEpisode.number - 1) ep.", attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.available.color])
                    }
                }
                else {
                    if nextEpisode.number == 1 {
                        rightLabel.attributedText = NSAttributedString(string: "Airs \(nextEpisode.localTimeDisplayString())", attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.regular.color])
                    }
                    else if anime.watchedEpisodes + 1 >= nextEpisode.number {
                        rightLabel.attributedText = NSAttributedString(string: "ep. \(nextEpisode.number) \(nextEpisode.localTimeDisplayString(context: .needsSeparator))", attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.upToDate.color])
                    }
                    else {
                        rightLabel.attributedText = NSAttributedString(string: "\(nextEpisode.number - 1) ep. aired", attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.available.color])
                    }
                }
            }
            else if anime.animeSeries.animeStatus != .finishedAiring {
                rightLabel.attributedText = NSAttributedString(string: anime.animeSeries.animeStatus.displayString, attributes: [NSAttributedStringKey.foregroundColor: theme.airingTime.regular.color])
            }
            else {
                rightLabel.attributedText = NSAttributedString(string: anime.animeSeries.animeType.displayString, attributes: [NSAttributedStringKey.foregroundColor: theme.entity.type.color])
            }
        }
        
        updateEditingStatus()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanup()
    }
    
    func setEpisodesButtonEnabled(_ enabled: Bool) {
        if enabled {
            addEpisodesButton.alpha = 1
            addEpisodesButton.isEnabled = true
            addEpisodesOverlayButton?.isEnabled = true
        }
        else {
            addEpisodesButton.alpha = 0.5
            addEpisodesButton.isEnabled = false
            addEpisodesOverlayButton?.isEnabled = false
        }
    }
    
    func updateEpisodesLabel() {
        episodesLabel.attributedText = UserAnimeRepresentation.attributedEpisodesCounter(for: changes)
    }
    
    @IBAction func addPressed() {
        performAdd(actionSelector: #selector(self.addFired(_:)))
    }
    
    @objc func addFired(_ timer: Timer) {
        addTimerDidFire(timer)
    }
}
