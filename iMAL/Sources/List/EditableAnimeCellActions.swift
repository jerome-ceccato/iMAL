//
//  EditableAnimeCellActions.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

protocol EditableAnimeCellActions: EditableAnimeCell {
    var changes: AnimeChanges! { get set }
    var addTimer: Timer? { get set }
    
    func setEpisodesButtonEnabled(_ enabled: Bool)
    func updateEpisodesLabel()
}

extension EditableAnimeCellActions {
    func cleanup() {
        if addTimer != nil {
            addTimerDidFire(addTimer!)
        }
    }
    
    func updateEditingStatus() {
        setEpisodesButtonEnabled(delegate?.canEditCell(self) ?? false)
    }
    
    func performAdd(actionSelector: Selector) {
        if let timer = addTimer {
            timer.invalidate()
            addTimer = nil
        }
        else if !(delegate?.lockEditingToCell(self) ?? false) {
            return
        }
        
        if changes.originalAnime.animeSeries.episodes > 0  && changes.watchedEpisodes + 1 >= changes.originalAnime.animeSeries.episodes {
            changes.watchedEpisodes = changes.originalAnime.animeSeries.episodes
            changes.status = .completed
            changes.restarting = false
            if Settings.enableAutomaticDates && changes.originalAnime.endDate == nil {
                changes.endDate = Date()
            }
            
            if let delegate = delegate {
                delegate.shouldShowScorePickerForUpdate(cell: self, currentScore: changes.originalAnime.score) { score in
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
            changes.watchedEpisodes += 1
            addTimer = Timer.scheduledTimer(timeInterval: Settings.listIncrementDelay, target: self, selector: actionSelector, userInfo: nil, repeats: false)
        }
        
        updateEpisodesLabel()
    }
    
    func addTimerDidFire(_ timer: Timer) {
        addTimer = nil
        
        setEpisodesButtonEnabled(false)
        
        trackChanges()
        
        let currentChanges = changes
        changes = AnimeChanges(anime: changes.originalAnime)
        delegate?.animeDidUpdate(currentChanges!, loadingDelegate: nil, completion: {
            self.setEpisodesButtonEnabled(true)
            self.delegate?.unlockEditing()
        })
    }
    
    private func trackChanges() {
        let episodesDifference = changes.watchedEpisodes - changes.originalAnime.watchedEpisodes
        if episodesDifference > 0 {
            Analytics.track(event: .addedEpisodes(episodesDifference))
        }
    }
}
