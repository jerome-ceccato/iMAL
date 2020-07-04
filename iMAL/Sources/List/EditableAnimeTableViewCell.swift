//
//  EditableAnimeTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableAnimeTableViewCell: AnimeTableViewCell, EditableAnimeCellActions {
    weak var delegate: EditableAnimeActionDelegate?
    
    @IBOutlet var addEpisodesButtonContainerView: UIView!
    @IBOutlet var addEpisodesButton: UIButton!
    @IBOutlet var addEpisodesOverlayButton: UIButton?
    
    var changes: AnimeChanges!
    var addTimer: Timer?
    
    override var canDisplayEditingControls: Bool {
        return true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addEpisodesButtonContainerView.layer.borderWidth = 1.5
        addEpisodesButtonContainerView.layer.cornerRadius = 4
        addEpisodesButtonContainerView.layer.masksToBounds = true
        
        applyTheme { [unowned self] theme in
            self.addEpisodesButton.setTitleColor(theme.entity.incrementButton.color, for: .normal)
            self.addEpisodesButtonContainerView.layer.borderColor = theme.entity.incrementButton.color.cgColor
        }
    }
    
    override func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        super.fill(withUserEntity: entity, metadata: metadata)
        
        if let anime = entity as? UserAnime {
            changes = AnimeChanges(anime: anime)
            addEpisodesButtonContainerView.isHidden = anime.sortingStatus != .watching
            addEpisodesOverlayButton?.isHidden = addEpisodesButtonContainerView.isHidden
            
            addEpisodesButton.isEnabled = !addEpisodesButtonContainerView.isHidden
            addEpisodesOverlayButton?.isEnabled = addEpisodesButton.isEnabled
        }
        
        updateEditingStatus()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanup()
    }
    
    func setEpisodesButtonEnabled(_ enabled: Bool) {
        if enabled {
            addEpisodesButtonContainerView.alpha = 1
            addEpisodesButton.isEnabled = true
            addEpisodesOverlayButton?.isEnabled = true
        }
        else {
            addEpisodesButtonContainerView.alpha = 0.5
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
