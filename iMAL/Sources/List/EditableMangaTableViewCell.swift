//
//  EditableMangaTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableMangaTableViewCell: MangaTableViewCell, EditableMangaCell {
    weak var delegate: EditableMangaActionDelegate?
    
    @IBOutlet var addChaptersButtonContainerView: UIView!
    @IBOutlet var addVolumesButtonContainerView: UIView!
    
    @IBOutlet var addChaptersButton: UIButton!
    @IBOutlet var addVolumesButton: UIButton!
    @IBOutlet var addChaptersOverlayButton: UIButton?
    @IBOutlet var addVolumesOverlayButton: UIButton?
    
    @IBOutlet var addChaptersButtonHiddenConstraint: NSLayoutConstraint!
    @IBOutlet var addVolumesButtonHiddenConstraint: NSLayoutConstraint!
    
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
        
        [addChaptersButtonContainerView, addVolumesButtonContainerView].forEach { containerView in
            containerView?.layer.borderWidth = 1.5
            containerView?.layer.cornerRadius = 4
            containerView?.layer.masksToBounds = true
        }
        
        applyTheme { [unowned self] theme in
            [self.addChaptersButton, self.addVolumesButton].forEach { buttonView in
                buttonView?.setTitleColor(theme.entity.incrementButton.color, for: .normal)
            }
            [self.addChaptersButtonContainerView, self.addVolumesButtonContainerView].forEach { containerView in
                containerView?.layer.borderColor = theme.entity.incrementButton.color.cgColor
            }
        }
    }
    
    override func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        super.fill(withUserEntity: entity, metadata: metadata)
        
        if let manga = entity as? UserManga {
            changes = MangaChanges(manga: manga)
            addChaptersButtonContainerView.isHidden = manga.sortingStatus != .watching
            addVolumesButtonContainerView.isHidden = addChaptersButtonContainerView.isHidden
            addChaptersOverlayButton?.isHidden = addChaptersButtonContainerView.isHidden
            addVolumesOverlayButton?.isHidden = addChaptersButtonContainerView.isHidden
            
            addChaptersButton.isEnabled = !addChaptersButtonContainerView.isHidden
            addVolumesButton.isEnabled = addChaptersButton.isEnabled
            addChaptersOverlayButton?.isEnabled = addChaptersButton.isEnabled
            addVolumesOverlayButton?.isEnabled = addVolumesButton.isEnabled
            
            addChaptersButtonHiddenConstraint.isActive = addChaptersButton.isEnabled
            addVolumesButtonHiddenConstraint.isActive = addChaptersButtonHiddenConstraint.isActive
        }
        
        updateEditingStatus()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if addTimer != nil {
            addFired(addTimer!)
        }
    }
    
    func updateEditingStatus() {
        if delegate?.canEditCell(self) ?? false {
            [addChaptersButtonContainerView, addVolumesButtonContainerView].forEach { $0.alpha = 1 }
            [addChaptersButton, addVolumesButton, addChaptersOverlayButton, addVolumesOverlayButton].forEach { $0?.isEnabled = true }
        }
        else {
            [addChaptersButtonContainerView, addVolumesButtonContainerView].forEach { $0.alpha = 0.5 }
            [addChaptersButton, addVolumesButton, addChaptersOverlayButton, addVolumesOverlayButton].forEach { $0?.isEnabled = false }
        }
    }
    
    @IBAction func addChapterPressed() {
        addPressed(.chapters)
    }
    
    @IBAction func addVolumePressed() {
        addPressed(.volumes)
    }
    
    func addPressed(_ value: SelectedValue) {
        if let timer = addTimer {
            timer.invalidate()
            addTimer = nil
        }
        else if !(delegate?.lockEditingToCell(self) ?? false) {
            return
        }
        
        if (value == .chapters && changes.originalManga.mangaSeries.chapters > 0 && changes.readChapters + 1 >= changes.originalManga.mangaSeries.chapters)
        || (value == .volumes && changes.originalManga.mangaSeries.volumes > 0 && changes.readVolumes + 1 >= changes.originalManga.mangaSeries.volumes) {
            if changes.originalManga.mangaSeries.chapters > 0 {
                changes.readChapters = changes.originalManga.mangaSeries.chapters
            }
            if changes.originalManga.mangaSeries.volumes > 0 {
                changes.readVolumes = changes.originalManga.mangaSeries.volumes
            }
            
            changes.status = .completed
            changes.restarting = false
            if Settings.enableAutomaticDates && changes.originalManga.endDate == nil {
                changes.endDate = Date()
            }
            
            if let delegate = delegate {
                delegate.shouldShowScorePickerForUpdate(cell: self, currentScore: changes.originalManga.score) { score in
                    if let score = score {
                        self.changes.score = score
                    }
                    self.addFired(Timer())
                }
            }
            else {
                addTimer = Timer.scheduledTimer(timeInterval: Settings.listIncrementDelay, target: self, selector: #selector(self.addFired(_:)), userInfo: nil, repeats: false)
            }
        }
        else {
            switch value {
            case .chapters:
                changes.readChapters += 1
            case .volumes:
                changes.readVolumes += 1
            }
            
            addTimer = Timer.scheduledTimer(timeInterval: Settings.listIncrementDelay, target: self, selector: #selector(self.addFired(_:)), userInfo: nil, repeats: false)
        }
        
        let fontSize = estimatedFontSizeForMangaCounters(changes.originalManga)
        chaptersLabel.attributedText = UserMangaRepresentation.attributedChaptersCounter(for: changes, fontSize: fontSize)
        volumesLabel.attributedText = UserMangaRepresentation.attributedVolumesCounter(for: changes, fontSize: fontSize)
    }
    
    @objc func addFired(_ timer: Timer) {
        addTimer = nil
        
        [addChaptersButtonContainerView, addVolumesButtonContainerView].forEach { $0.alpha = 0.5 }
        [addChaptersButton, addVolumesButton].forEach { $0.isEnabled = false }
        
        trackChanges()
        
        let currentChanges = changes
        changes = MangaChanges(manga: changes.originalManga)
        delegate?.mangaDidUpdate(currentChanges!, loadingDelegate: nil, completion: {
            [self.addChaptersButton, self.addVolumesButton].forEach { $0.isEnabled = true }
            self.delegate?.unlockEditing()
        })
    }
    
    private func trackChanges() {
        let volumesDifference = changes.readVolumes - changes.originalManga.readVolumes
        if volumesDifference > 0 {
            Analytics.track(event: .addedVolumes(volumesDifference))
        }
        
        let chaptersDifference = changes.readChapters - changes.originalManga.readChapters
        if chaptersDifference > 0 {
            Analytics.track(event: .addedChapters(chaptersDifference))
        }
    }
}

