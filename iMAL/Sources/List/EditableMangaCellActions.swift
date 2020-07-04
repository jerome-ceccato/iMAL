//
//  EditableMangaCellActions.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

enum EditableMangaCellSelectedValue {
    case chapters
    case volumes
}

protocol EditableMangaCellActions: EditableMangaCell {
    var changes: MangaChanges! { get set }
    var addTimer: Timer? { get set }
    
    func setVolumesChaptersButtonsEnabled(_ enabled: Bool)
    func updateVolumesChaptersLabels()
}

extension EditableMangaCellActions {
    func cleanup() {
        if addTimer != nil {
            addTimerDidFire(addTimer!)
        }
    }
    
    func updateEditingStatus() {
        setVolumesChaptersButtonsEnabled(delegate?.canEditCell(self) ?? false)
    }
    
    func performAddChapter(actionSelector: Selector) {
        performAdd(.chapters, actionSelector: actionSelector)
    }
    
    func performAddVolume(actionSelector: Selector) {
        performAdd(.volumes, actionSelector: actionSelector)
    }
    
    func performAdd(_ value: EditableMangaCellSelectedValue, actionSelector: Selector) {
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
                    self.addTimerDidFire(Timer())
                }
            }
            else {
                addTimer = Timer.scheduledTimer(timeInterval: Settings.listIncrementDelay, target: self, selector: actionSelector, userInfo: nil, repeats: false)
            }
        }
        else {
            switch value {
            case .chapters:
                changes.readChapters += 1
            case .volumes:
                changes.readVolumes += 1
            }
            
            addTimer = Timer.scheduledTimer(timeInterval: Settings.listIncrementDelay, target: self, selector: actionSelector, userInfo: nil, repeats: false)
        }
        
        updateVolumesChaptersLabels()
    }
    
    func addTimerDidFire(_ timer: Timer) {
        addTimer = nil
        
        setVolumesChaptersButtonsEnabled(false)
        
        trackChanges()
        
        let currentChanges = changes
        changes = MangaChanges(manga: changes.originalManga)
        delegate?.mangaDidUpdate(currentChanges!, loadingDelegate: nil, completion: {
            self.setVolumesChaptersButtonsEnabled(true)
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
