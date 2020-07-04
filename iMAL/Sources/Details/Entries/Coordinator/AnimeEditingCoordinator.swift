//
//  AnimeEditingCoordinator.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimeEditingCoordinator: EntityEditingCoordinator {
    var animeChanges: AnimeChanges! {
        return changes as? AnimeChanges
    }
    
    var originalAnime: UserAnime! {
        return animeChanges.originalAnime
    }
    
    var episodesUserEntry: EditableEpisodesEntryView!
    
    func updateFields(with newAnime: UserAnime) {

        if changes == nil {
            changes = AnimeChanges(anime: newAnime)
        }
        else {
            changes.originalEntity = newAnime
        }

        setEntriesCoordinator()
        [episodesUserEntry].forEach { entry in
            entry.coordinator = self
        }
        
        updateAllFields()
    }
    
    override func updateAllFields() {
        super.updateAllFields()
        
        episodesUserEntry.content = "\(animeChanges.watchedEpisodes)"
        episodesUserEntry.additionalRightText = originalAnime.animeSeries.episodes > 0 ? " / \(originalAnime.animeSeries.episodes)" : nil
    }
    
    override func statusDisplayStrings() -> [String] {
        return UserAnime.Status.displayStrings
    }
    
    override func updateStatus(withSelectedString status: String) {
        let shouldRevertEpisodes = animeChanges.status == .completed && !animeChanges.restarting && (originalAnime.status != .completed || originalAnime.restarting)
        
        animeChanges.restarting = status == UserAnime.Status.specialStatus
        changes.status = UserAnime.Status.statusForDisplayString(status)
        
        if (changes.status != .completed || animeChanges.restarting) {
            if shouldRevertEpisodes && numberOfEpisodesInSeries() > 0 {
                animeChanges.watchedEpisodes = originalAnime.watchedEpisodes
                episodesUserEntry.updateWatchedEpisodes(originalAnime.watchedEpisodes)
            }
            
            automaticallyFill(dates: .both, with: nil)
        }
        else {
            if originalAnime.status == .planToWatch {
                automaticallyFill(dates: .start, with: Date())
            }
            
            if changes.status == .completed && !animeChanges.restarting {
                automaticallyFill(dates: .end, with: Date())
                if numberOfEpisodesInSeries() > 0 {
                    animeChanges.watchedEpisodes = numberOfEpisodesInSeries()
                    episodesUserEntry.updateWatchedEpisodes(numberOfEpisodesInSeries())
                }
            }
        }
        
        if originalAnime.status == .planToWatch && changes.status != .planToWatch {
            automaticallyFill(dates: .start, with: Date())
        }
        
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    func numberOfEpisodesInSeries() -> Int {
        return originalAnime.animeSeries.episodes
    }
    
    func updateEpisodeCount(_ count: Int) {
        animeChanges.watchedEpisodes = count
        
        if count == numberOfEpisodesInSeries() && numberOfEpisodesInSeries() > 0 {
            changes.status = .completed
            animeChanges.restarting = false
            statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
            automaticallyFill(dates: .end, with: Date())
        }
        else if numberOfEpisodesInSeries() > 0 && (changes.status == .completed && !animeChanges.restarting) && (originalAnime.status != .completed || originalAnime.restarting) {
            changes.status = originalAnime.status
            animeChanges.restarting = originalAnime.restarting
            statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
            automaticallyFill(dates: .end, with: nil)
        }
        if changes.status == .planToWatch && originalAnime.status == .planToWatch && count > 0 {
            changes.status = .watching
            statusUserEntry.content = changes.statusDisplayString
            automaticallyFill(dates: .start, with: Date())
        }
        else if changes.status != .planToWatch && originalAnime.status == .planToWatch && count == 0 {
            changes.status = .planToWatch
            statusUserEntry.content = changes.statusDisplayString
            automaticallyFill(dates: .both, with: nil)
        }
        delegate?.changesDidUpdate(coordinator: self)
    }

    // MARK: - Server update

    override func apiUpdateEntityMethod(changes: EntityChanges) -> API! {
        return API.updateAnime(changes: changes as! AnimeChanges)
    }
    
    override func changes(forNewTags tags: [String]) -> EntityChanges! {
        let changes = AnimeChanges(anime: self.animeChanges.originalAnime)
        changes.tags = tags
        return changes
    }
}
