//
//  Database.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 22/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import SwiftyJSON

class Database {
    static var shared: Database = Database()
    private init() {
        loadAiringDataFromCacheIfNeeded()
    }
    
    private(set) var airingAnime: AiringData?
    private var loadingAiringData: Bool = false
}

// MARK: - Global configs
extension Database {
    var entitiesTableViewHeaderHeight: CGFloat {
        return 36
    }
}

// MARK: - Friends
extension Database {
    fileprivate static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    fileprivate static let friendsArchiveURL = documentsDirectory.appendingPathComponent("imal_friends")
    
    class func loadFriends() -> [Friend] {
        return SafeArchiver.unarchiveObject(withFile: friendsArchiveURL.path) as? [Friend] ?? []
    }
    
    class func saveFriends(_ friends: [Friend]) {
        SafeArchiver.archiveRootObject(friends, toFile: friendsArchiveURL.path)
    }
}

// MARK: - Airing
extension Database {
    fileprivate static let airingDataArchiveURL = documentsDirectory.appendingPathComponent("imal_airing_data")
    private static let animeAiringDataAvailableNotification = "imal-anime-airing-available"
    
    private func loadCachedAiringData() -> AiringData? {
        do {
            let data = try Data(contentsOf: Database.airingDataArchiveURL)
            let json = try JSON(data: data)
            return AiringData(json: json)
        }
        catch {
            print(error)
        }
        return nil
    }
    
    private func cacheAiringData(json: JSON) {
        do {
            let data = try json.rawData()
            try data.write(to: Database.airingDataArchiveURL, options: .atomic)
        }
        catch {
            print(error)
        }
    }
    
    func clearAiringDataCache() {
        try? FileManager.default.removeItem(at: Database.airingDataArchiveURL)
    }
    
    private func loadAiringAnimeData() {
        if !loadingAiringData && Settings.airingDatesEnabled {
            loadingAiringData = true
            
            API.airingAnime.request() { (success: Bool, rawdata: JSON?) in
                if success, let json = rawdata {
                    let data = AiringData(json: json)
                    self.airingAnime = data
                    self.cacheAiringData(json: json)
                    self.broadcastAnimeAiringDataAvailableNotification()
                }
                self.loadingAiringData = false
            }
        }
    }
    
    func loadAiringDataFromCacheIfNeeded(notifyOnLoad: Bool = false) {
        if Settings.airingDatesEnabled && airingAnime == nil {
            airingAnime = loadCachedAiringData()
            if airingAnime != nil && notifyOnLoad {
                self.broadcastAnimeAiringDataAvailableNotification()
            }
        }
    }
    
    func updateAiringAnimeDataIfNeeded() {
        loadAiringDataFromCacheIfNeeded(notifyOnLoad: true)
        
        if let lastUpdate = airingAnime?.lastUpdate {
            if lastUpdate.addingTimeInterval(3600) < Date() {
                loadAiringAnimeData()
            }
        }
        else {
            loadAiringAnimeData()
        }
    }
    
    func invalidateAiringTimeOffset() {
        if airingAnime != nil {
            broadcastAnimeAiringDataAvailableNotification()
        }
    }

    // -- Notifications
    
    private func broadcastAnimeAiringDataAvailableNotification() {
        Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: Database.animeAiringDataAvailableNotification), object: nil)
    }
    
    func handleAnimeAiringDataAvailableNotification(_ object: AnyObject, update: @escaping () -> Void) {
        NotificationCenter.register(object, Database.animeAiringDataAvailableNotification, block: { notif in
            update()
        })
    }
}

// MARK: - Filter
extension Database {
    private static let rxFilterChangedNotification = "imal-rating-filter-changed"

    // -- Notifications
    
    func broadcastRxFilterChangedNotification() {
        Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: Database.rxFilterChangedNotification), object: nil)
    }
    
    func handleRxFilterChangedNotification(_ object: AnyObject, update: @escaping () -> Void) {
        NotificationCenter.register(object, Database.rxFilterChangedNotification, block: { notif in
            update()
        })
    }
}

