//
//  AnimeChanges.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

class AnimeChanges: EntityChanges {
    var originalAnime: UserAnime! {
        return originalEntity as? UserAnime
    }
    
    var watchedEpisodesChanges: Int?
    
    override var specialStatus: String? {
        return restarting ? UserAnime.Status.specialStatus : nil
    }
    
    override var statusDisplayString: String {
        return UserAnime.Status.displayString(status)
    }

    init(anime: UserAnime) {
        super.init()
        
        originalEntity = anime
    }
    
    // MARK: - Accessors

    var watchedEpisodes: Int {
        get {
            return watchedEpisodesChanges ?? originalAnime.watchedEpisodes
        }
        set {
            watchedEpisodesChanges = newValue
        }
    }

    // MARK: - Actions
    
    override func toUpdateParameters() -> [String : AnyObject] {
        var data = super.toUpdateParameters()
        
        if let newEpisodes = watchedEpisodesChanges {
            data["episode"] = newEpisodes as AnyObject
        }
        if let newRewatching = restartingChanges {
            data["enable_rewatching"] = (newRewatching ? "1" : "0") as AnyObject
        }
        if let rewatchCount = restartCount {
            data["times_rewatched"] = rewatchCount as AnyObject
        }
        
        return data
    }
    
    override func commitChanges() {
        super.commitChanges()
        
        originalAnime.watchedEpisodes = watchedEpisodes

        revertChanges()
    }
    
    override func revertChanges() {
        super.revertChanges()
        
        watchedEpisodesChanges = nil
    }
    
    override func hasChanges() -> Bool {
        return super.hasChanges() || watchedEpisodesChanges != nil
    }
}
