//
//  Analytics.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 01/10/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import Firebase

class Analytics {
    class func setup() {
        FirebaseApp.configure()
    }
    
    class func appDidOpen() {
        Firebase.Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    class func track(view: Analytics.View) {
        print("[Firebase] view \(view.eventName)")
        Firebase.Analytics.logEvent(view.eventName, parameters: view.eventParameters)
    }
    
    class func track(event: Analytics.Event) {
        print("[Firebase] event \(event.eventName) - \(event.eventParameters ?? [:])")
        Firebase.Analytics.logEvent(event.eventName, parameters: event.eventParameters)
    }
}

// MARK: - Views
extension Analytics {
    enum View {
        case login
        case userAnimeList
        case userMangaList
        case animePreview
        case mangaPreview
        case animeDetails
        case mangaDetails
        case animeSearch
        case mangaSearch
        case settings
        
        case friendAnimeList
        case friendMangaList
    }
}

extension Analytics.View {
    static let eventPrefix = "view_"
    
    var eventName: String {
        return Analytics.View.eventPrefix + eventAnalyticsName()
    }
    
    var eventParameters: [String: NSObject]? {
        let entityTypeKey = "entity"
        
        switch self {
        case .userAnimeList, .animePreview, .animeDetails, .animeSearch, .friendAnimeList:
            return [entityTypeKey: "anime" as NSObject]
        case .userMangaList, .mangaPreview, .mangaDetails, .mangaSearch, .friendMangaList:
            return [entityTypeKey: "manga" as NSObject]
        default:
            return nil
        }
    }
    
    private func eventAnalyticsName() -> String {
        switch self {
        case .login:
            return "login"
        case .userAnimeList, .userMangaList:
            return "user_list"
        case .animePreview, .mangaPreview:
            return "entity_preview"
        case .animeDetails, .mangaDetails:
            return "entity_details"
        case .animeSearch, .mangaSearch:
            return "entity_search"
        case .settings:
            return "settings"
        case .friendAnimeList, .friendMangaList:
            return "friend_list"
        }
    }
}

// MARK: - Events
extension Analytics {
    enum EntityType: String {
        case anime = "anime"
        case manga = "manga"
    }
    
    enum Event {
        case addedEpisodes(_: Int)
        case addedVolumes(_: Int)
        case addedChapters(_: Int)
        case search(_: EntityType)
        case addedEntity(_: EntityType)
        case updatedEntity(_: EntityType)
        case deletedEntity(_: EntityType)
        case showRelated
        case previewAction(_: EntityType, _: EntityPreviewViewController.Action)
    }
}

extension Analytics.Event {
    static let eventPrefix = "event_"
    
    var eventName: String {
        return Analytics.Event.eventPrefix + eventAnalyticsName()
    }
    
    var eventParameters: [String: NSObject]? {
        let entityTypeKey = "entity"
        let actionKey = "action"
        let addedAmountKey = "n"
        
        switch self {
        case .addedEpisodes(let n):
            return [addedAmountKey: n as NSObject]
        case .addedVolumes(let n):
            return [addedAmountKey: n as NSObject]
        case .addedChapters(let n):
            return [addedAmountKey: n as NSObject]
        case .search(let type):
            return [entityTypeKey: type.rawValue as NSObject]
        case .addedEntity(let type):
            return [entityTypeKey: type.rawValue as NSObject]
        case .updatedEntity(let type):
            return [entityTypeKey: type.rawValue as NSObject]
        case .deletedEntity(let type):
            return [entityTypeKey: type.rawValue as NSObject]
        case .previewAction(let type, let action):
            return [entityTypeKey: type.rawValue as NSObject,
                    actionKey: previewActionName(action) as NSObject]
        default:
            return nil
        }
    }
    
    private func previewActionName(_ action: EntityPreviewViewController.Action) -> String {
        switch action {
        case .watching:
            return "set_watching"
        case .completed:
            return "set_completed"
        case .dropped:
            return "set_dropped"
        case .onHold:
            return "set_onhold"
        case .planned:
            return "set_planned"
        case .setMetrics:
            return "set_metrics"
        case .setScore:
            return "set_score"
        case .specialStatus:
            return "set_rewatching"
        case .removeFromList:
            return "set_remove"
        }
    }
    
    private func eventAnalyticsName() -> String {
        switch self {
        case .addedEpisodes:
            return "add_episode"
        case .addedVolumes:
            return "add_volume"
        case .addedChapters:
            return "add_chapter"
        case .search:
            return "search"
        case .addedEntity:
            return "add"
        case .updatedEntity:
            return "update"
        case .deletedEntity:
            return "delete"
        case .showRelated:
            return "related"
        case .previewAction:
            return "quick_action"
        }
    }
}
