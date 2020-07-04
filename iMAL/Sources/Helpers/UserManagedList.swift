//
//  UserManagedList.swift
//  iMAL
//
//  Created by Jerome Ceccato on 13/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

enum ListUpdateType: Int {
    case add
    case update
    case delete
}

struct UserManagedList<T: IndexableList & Codable> {
    var list: T? = nil
    var lastListUpdate: Date?
    let cache: UserDataCache
    
    var synchronized = false
    var isSynchronizing = false
    
    private struct UserListUpdate {
        var type: ListUpdateType
        var entity: T.T
    }
    
    // Changes made during synchronization
    private var pendingChanges: [UserListUpdate] = []
    
    var editable: Bool {
        return synchronized || !Settings.preventEditingUntilSynched
    }
    
    var username: String {
        return CurrentUser.me.currentUsername
    }
    
    init(type: EntityKind) {
        cache = UserDataCache(type: type)
    }
    
    mutating func clear() {
        list = nil
        synchronized = false
        isSynchronizing = false
        pendingChanges.removeAll()
    }
    
    // Returns true if the list has been synchronized for the first time
    mutating func synchronizeFromRemote(_ list: T) -> Bool {
        self.list = applyPendingChangesIfNeeded(to: list)
        self.lastListUpdate = Date()
        
        synchronizeCache()
        
        if !synchronized {
            synchronized = true
            return true
        }
        return false
    }
    
    mutating func listOrCachedVersion() -> T? {
        if let list = list {
            return list
        }
        
        list = cache.cachedList(for: username)
        return list
    }
    
    mutating func synchronizeCache() {
        if let list = list {
            cache.save(list: list, for: username)
        }
    }
    
    // Returns true if the cache was invalidated
    mutating func invalidateMemoryCache(ifPriorToDate date: Date) -> Bool {
        if let lastUpdate = lastListUpdate, synchronized, !isSynchronizing {
            if lastUpdate < date {
                lastListUpdate = nil
                synchronized = false
                return true
            }
        }
        return false
    }
    
    // Called when a change is made, if the list is not synchronized yet we want to save these changes and apply them after the synchronization is made
    mutating func userDidUpdateList(type: ListUpdateType, entity: T.T) {
        guard isSynchronizing && !synchronized else {
            return
        }
        
        pendingChanges.append(UserListUpdate(type: type, entity: entity))
    }
    
    private mutating func applyPendingChangesIfNeeded(to list: T) -> T {
        if !pendingChanges.isEmpty {
            for item in pendingChanges {
                if let existingIndex = list.items.index(where: { $0.series.identifier == item.entity.series.identifier }) {
                    list.items.remove(at: existingIndex)
                }
                if item.type != .delete {
                    list.items.append(item.entity)
                }
            }
            
            pendingChanges.removeAll()
            list.invalidateSearchIndex()
        }
        return list
    }
}
