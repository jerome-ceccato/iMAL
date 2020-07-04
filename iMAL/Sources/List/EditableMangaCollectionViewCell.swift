//
//  EditableMangaCollectionViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EditableMangaCollectionViewCell: MangaCollectionViewCell, EditableMangaCellActions {
    weak var delegate: EditableMangaActionDelegate?
    
    @IBOutlet var bottomContainerView: UIView!
    
    @IBOutlet var chaptersLabel: UILabel!
    @IBOutlet var volumesLabel: UILabel!
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var scoreImageView: UIImageView!
    @IBOutlet var scoreContainerView: RoundCornersView!
    
    @IBOutlet var topContainerView: RoundCornersView!
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var addChaptersButtonContainerView: RoundCornersView!
    @IBOutlet var addVolumesButtonContainerView: RoundCornersView!
    
    @IBOutlet var addChaptersButton: UIButton!
    @IBOutlet var addVolumesButton: UIButton!
    @IBOutlet var addChaptersOverlayButton: UIButton?
    @IBOutlet var addVolumesOverlayButton: UIButton?
    @IBOutlet var addChaptersContainerSizeConstraint: NSLayoutConstraint!
    @IBOutlet var addVolumesContainerSizeConstraint: NSLayoutConstraint!
    
    var changes: MangaChanges!
    var addTimer: Timer?
    
    enum SelectedValue {
        case chapters
        case volumes
    }
    
    override var canDisplayEditingControls: Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        topContainerView.corners = .bottomLeft
        addChaptersButtonContainerView.corners = .topLeft
        addVolumesButtonContainerView.corners = .topRight
        scoreContainerView.corners = .topLeft
        
        applyTheme { [unowned self] theme in
            [self.bottomContainerView!,
             self.scoreContainerView!,
             self.addChaptersButtonContainerView!,
             self.addVolumesButtonContainerView!].forEach { container in
                container.backgroundColor = theme.entity.cardsInfoBackground.color
            }
            self.topContainerView.backgroundColor = theme.entity.cardsInfoOverlayBackground.color
            
            self.scoreLabel.textColor = theme.entity.score.color
            self.scoreImageView.tintColor = theme.entity.score.color
        }
    }
    
    override func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        super.fill(withUserEntity: entity, metadata: metadata)
        
        if let manga = entity as? UserManga {
            changes = MangaChanges(manga: manga)
            
            let hasAddButtons = manga.sortingStatus == .watching
            
            addChaptersButtonContainerView.isHidden = !hasAddButtons
            addVolumesButtonContainerView.isHidden = addChaptersButtonContainerView.isHidden
            addChaptersOverlayButton?.isHidden = addChaptersButtonContainerView.isHidden
            addVolumesOverlayButton?.isHidden = addChaptersButtonContainerView.isHidden
            
            addChaptersButton.isEnabled = !addChaptersButtonContainerView.isHidden
            addVolumesButton.isEnabled = addChaptersButton.isEnabled
            addChaptersOverlayButton?.isEnabled = addChaptersButton.isEnabled
            addVolumesOverlayButton?.isEnabled = addVolumesButton.isEnabled
            
            if let metadata = metadata, metadata.style == .collectionViewSmall {
                addChaptersButton.setTitle("+ C", for: .normal)
                addVolumesButton.setTitle("+ V", for: .normal)
                
                addChaptersContainerSizeConstraint.constant = 36
                addVolumesContainerSizeConstraint.constant = 36
            }
            else {
                addChaptersButton.setTitle("+ CH", for: .normal)
                addVolumesButton.setTitle("+ VOL", for: .normal)
                
                addChaptersContainerSizeConstraint.constant = 50
                addVolumesContainerSizeConstraint.constant = 55
            }
            
            updateVolumesChaptersLabels()
            
            if hasAddButtons {
                scoreContainerView.isHidden = true
            }
            else {
                scoreLabel.text = "\(manga.score)"
                scoreContainerView.isHidden = manga.score < 1
            }
            
            if metadata?.wantsFullStatus ?? false {
                statusLabel.attributedText = NSAttributedString(string: manga.specialStatus ?? manga.statusDisplayString, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                topContainerView.backgroundColor = manga.status.colorCode()
                topContainerView.isHidden = false
            }
            else {
                topContainerView.isHidden = true
            }
        }
        
        updateEditingStatus()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanup()
    }
    
    func setVolumesChaptersButtonsEnabled(_ enabled: Bool) {
        if delegate?.canEditCell(self) ?? false {
            [addChaptersButtonContainerView, addVolumesButtonContainerView].forEach { $0.alpha = 1 }
            [addChaptersButton, addVolumesButton, addChaptersOverlayButton, addVolumesOverlayButton].forEach { $0?.isEnabled = true }
        }
        else {
            [addChaptersButtonContainerView, addVolumesButtonContainerView].forEach { $0.alpha = 0.5 }
            [addChaptersButton, addVolumesButton, addChaptersOverlayButton, addVolumesOverlayButton].forEach { $0?.isEnabled = false }
        }
    }
  
    func updateVolumesChaptersLabels() {
        if (changes.status == .completed && !changes.restarting) || (metadata?.style ?? .tableViewDefault) == .collectionViewSmall {
            let fontSize: CGFloat = 12
            
            if changes.status == .planToWatch {
                chaptersLabel.attributedText = UserEntityAttributedRepresentation.attributedCounter(withCurrent: 0, total: changes.originalManga.mangaSeries.chapters, suffix: " Ch.", fontSize: fontSize)
                volumesLabel.attributedText = UserEntityAttributedRepresentation.attributedCounter(withCurrent: 0, total: changes.originalManga.mangaSeries.volumes, suffix: " Vol.", fontSize: fontSize)
            }
            else {
                chaptersLabel.attributedText = UserEntityAttributedRepresentation.attributedCounter(withCurrent: changes.readChapters, total: 0, prefix: "Ch. ", fontSize: fontSize)
                volumesLabel.attributedText = UserEntityAttributedRepresentation.attributedCounter(withCurrent: changes.readVolumes, total: 0, prefix: "Vol. ", fontSize: fontSize)
            }
        }
        else {
            let fontSize: CGFloat = 14
            chaptersLabel.attributedText = UserMangaRepresentation.attributedChaptersCounter(for: changes, fontSize: fontSize)
            volumesLabel.attributedText = UserMangaRepresentation.attributedVolumesCounter(for: changes, fontSize: fontSize)
        }
    }
    
    @IBAction func addChaptersPressed() {
        performAddChapter(actionSelector: #selector(self.addFired(_:)))
    }
    
    @IBAction func addVolumesPressed() {
        performAddVolume(actionSelector: #selector(self.addFired(_:)))
    }
    
    @objc func addFired(_ timer: Timer) {
        addTimerDidFire(timer)
    }
}
