//
//  MangaEditingCoordinator.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaEditingCoordinator: EntityEditingCoordinator {
    var mangaChanges: MangaChanges! {
        return changes as? MangaChanges
    }
    
    var originalManga: UserManga! {
        return mangaChanges.originalManga
    }
    
    var chaptersUserEntry: EditableChaptersEntryView!
    var volumesUserEntry: EditableVolumesEntryView!
    
    func updateFields(with newManga: UserManga) {
        if changes == nil {
            changes = MangaChanges(manga: newManga)
        }
        else {
            changes.originalEntity = newManga
        }
        
        setEntriesCoordinator()
        [chaptersUserEntry, volumesUserEntry].forEach { entry in
            entry.coordinator = self
        }
        
        updateAllFields()
    }
    
    override func updateAllFields() {
        super.updateAllFields()
        
        chaptersUserEntry.content = "\(mangaChanges.readChapters)"
        chaptersUserEntry.additionalRightText = originalManga.mangaSeries.chapters > 0 ? " / \(originalManga.mangaSeries.chapters)" : nil
        
        volumesUserEntry.content = "\(mangaChanges.readVolumes)"
        volumesUserEntry.additionalRightText = originalManga.mangaSeries.volumes > 0 ? " / \(originalManga.mangaSeries.volumes)" : nil
    }
    
    override func statusDisplayStrings() -> [String] {
        return UserManga.Status.displayStrings
    }
    
    override func updateStatus(withSelectedString status: String) {
        let shouldRevertChaptersVolumes = mangaChanges.status == .completed && !mangaChanges.restarting && (originalManga.status != .completed || originalManga.restarting)
        
        mangaChanges.restarting = status == UserManga.Status.specialStatus
        changes.status = UserManga.Status.statusForDisplayString(status)
        
        if (changes.status != .completed || mangaChanges.restarting) {
            if shouldRevertChaptersVolumes && (numberOfChaptersInSeries() > 0 || numberOfVolumesInSeries() > 0) {
                mangaChanges.readChapters = originalManga.readChapters
                chaptersUserEntry.updateReadChapters(originalManga.readChapters)
                
                mangaChanges.readVolumes = originalManga.readVolumes
                volumesUserEntry.updateReadVolumes(originalManga.readVolumes)
            }
            
            automaticallyFill(dates: .both, with: nil)
        }
        else {
            if originalManga.status == .planToWatch {
                automaticallyFill(dates: .start, with: Date())
            }
            
            if changes.status == .completed && !mangaChanges.restarting {
                automaticallyFill(dates: .end, with: Date())
                if numberOfChaptersInSeries() > 0 {
                    mangaChanges.readChapters = numberOfChaptersInSeries()
                    chaptersUserEntry.updateReadChapters(numberOfChaptersInSeries())
                }
                
                if numberOfVolumesInSeries() > 0 {
                    mangaChanges.readVolumes = numberOfVolumesInSeries()
                    volumesUserEntry.updateReadVolumes(numberOfVolumesInSeries())
                }
            }
        }
        
        if originalManga.status == .planToWatch && changes.status != .planToWatch {
            automaticallyFill(dates: .start, with: Date())
        }
        
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    func numberOfChaptersInSeries() -> Int {
        return originalManga.mangaSeries.chapters
    }
    
    func numberOfVolumesInSeries() -> Int {
        return originalManga.mangaSeries.volumes
    }
    
    func updateChapterCount(_ count: Int) {
        mangaChanges.readChapters = count
        
        if count == numberOfChaptersInSeries() && numberOfChaptersInSeries() > 0 {
            if numberOfVolumesInSeries() > 0 {
                mangaChanges.readVolumes = numberOfVolumesInSeries()
                volumesUserEntry.content = "\(mangaChanges.readVolumes)"
            }
            changes.status = .completed
            mangaChanges.restarting = false
            statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
            automaticallyFill(dates: .end, with: Date())
        }
        else if numberOfChaptersInSeries() > 0 && (changes.status == .completed && !mangaChanges.restarting) && (originalManga.status != .completed || originalManga.restarting) {
            changes.status = originalManga.status
            mangaChanges.restarting = originalManga.restarting
            statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
            if numberOfVolumesInSeries() > 0 && numberOfVolumesInSeries() == mangaChanges.readVolumes {
                mangaChanges.readVolumes = originalManga.readVolumes
                volumesUserEntry.content = "\(mangaChanges.readVolumes)"
            }
            automaticallyFill(dates: .end, with: nil)
        }
        if changes.status == .planToWatch && originalManga.status == .planToWatch && count > 0 {
            changes.status = .watching
            statusUserEntry.content = changes.statusDisplayString
            automaticallyFill(dates: .start, with: Date())
        }
        else if changes.status != .planToWatch && originalManga.status == .planToWatch && count == 0 && mangaChanges.readVolumes == 0 {
            changes.status = .planToWatch
            statusUserEntry.content = changes.statusDisplayString
            automaticallyFill(dates: .both, with: nil)
        }
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    func updateVolumeCount(_ count: Int) {
        mangaChanges.readVolumes = count
        
        if count == numberOfVolumesInSeries() && numberOfVolumesInSeries() > 0 {
            if numberOfChaptersInSeries() > 0 {
                mangaChanges.readChapters = numberOfChaptersInSeries()
                chaptersUserEntry.content = "\(mangaChanges.readChapters)"
            }
            changes.status = .completed
            mangaChanges.restarting = false
            statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
            automaticallyFill(dates: .end, with: Date())
        }
        else if numberOfVolumesInSeries() > 0 && (changes.status == .completed && !mangaChanges.restarting) && (originalManga.status != .completed || originalManga.restarting) {
            changes.status = originalManga.status
            mangaChanges.restarting = originalManga.restarting
            statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
            if numberOfChaptersInSeries() > 0 && numberOfChaptersInSeries() == mangaChanges.readChapters {
                mangaChanges.readChapters = originalManga.readChapters
                chaptersUserEntry.content = "\(mangaChanges.readChapters)"
            }
            automaticallyFill(dates: .end, with: nil)
        }
        if changes.status == .planToWatch && originalManga.status == .planToWatch && count > 0 {
            changes.status = .watching
            statusUserEntry.content = changes.statusDisplayString
            automaticallyFill(dates: .start, with: Date())
        }
        else if changes.status != .planToWatch && originalManga.status == .planToWatch && count == 0 && mangaChanges.readChapters == 0 {
            changes.status = .planToWatch
            statusUserEntry.content = changes.statusDisplayString
            automaticallyFill(dates: .both, with: nil)
        }
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    // MARK: - Server update
    
    override func apiUpdateEntityMethod(changes: EntityChanges) -> API! {
        return API.updateManga(changes: changes as! MangaChanges)
    }
    
    override func changes(forNewTags tags: [String]) -> EntityChanges! {
        let changes = MangaChanges(manga: self.mangaChanges.originalManga)
        changes.tags = tags
        return changes
    }
}

