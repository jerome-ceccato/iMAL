//
//  MangaChanges.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

class MangaChanges: EntityChanges {
    var originalManga: UserManga! {
        return originalEntity as? UserManga
    }
   
    var readChaptersChanges: Int?
    var readVolumesChanges: Int?
    
    override var specialStatus: String? {
        return restarting ? UserManga.Status.specialStatus : nil
    }
    
    override var statusDisplayString: String {
        return UserManga.Status.displayString(status)
    }
    
    init(manga: UserManga) {
        super.init()
        
        originalEntity = manga
    }
    
    // MARK: - Accessors
    
    var readChapters: Int {
        get {
            return readChaptersChanges ?? originalManga.readChapters
        }
        set {
            readChaptersChanges = newValue
        }
    }
    
    var readVolumes: Int {
        get {
            return readVolumesChanges ?? originalManga.readVolumes
        }
        set {
            readVolumesChanges = newValue
        }
    }
    
    // MARK: - Actions
    
    override func toUpdateParameters() -> [String : AnyObject] {
        var data = super.toUpdateParameters()
        
        if let newChapters = readChaptersChanges {
            data["chapter"] = newChapters as AnyObject?
        }
        if let newVolumes = readVolumesChanges {
            data["volume"] = newVolumes as AnyObject?
        }
        if let newRestarting = restartingChanges {
            data["enable_rereading"] = (newRestarting ? "1" : "0") as AnyObject?
        }
        if let restartCount = restartCount {
            data["times_reread"] = restartCount as AnyObject?
        }
        
        return data
    }
    
    override func commitChanges() {
        super.commitChanges()
        
        originalManga.readChapters = readChapters
        originalManga.readVolumes = readVolumes
        
        revertChanges()
    }
    
    override func revertChanges() {
        super.revertChanges()
        
        readChaptersChanges = nil
        readVolumesChanges = nil
    }
    
    override func hasChanges() -> Bool {
        return super.hasChanges()
            || readChaptersChanges != nil
            || readVolumesChanges != nil
    }
}
