//
//  UserDataObserving.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

class UserDataObserving {
    struct NotificationOptions: OptionSet {
        let rawValue: Int
        
        static let animeUpdate = NotificationOptions(rawValue: 1 << 0)
        static let animeAdd = NotificationOptions(rawValue: 1 << 1)
        static let animeDelete = NotificationOptions(rawValue: 1 << 2)
        static let anime: NotificationOptions = [.animeUpdate, .animeAdd, .animeDelete]
        
        static let mangaUpdate = NotificationOptions(rawValue: 1 << 3)
        static let mangaAdd = NotificationOptions(rawValue: 1 << 4)
        static let mangaDelete = NotificationOptions(rawValue: 1 << 5)
        static let manga: NotificationOptions = [.mangaUpdate, .mangaAdd, .mangaDelete]

        static let animeListSynchronized = NotificationOptions(rawValue: 1 << 6)
        static let mangaListSynchronized = NotificationOptions(rawValue: 1 << 7)
        static let synchronization: NotificationOptions = [.animeListSynchronized, .mangaListSynchronized]
        
        static let animeListWillRefresh = NotificationOptions(rawValue: 1 << 8)
        static let animeListDidRefresh = NotificationOptions(rawValue: 1 << 9)
        static let animeRefresh: NotificationOptions = [.animeListWillRefresh, .animeListDidRefresh]
        
        static let mangaListWillRefresh = NotificationOptions(rawValue: 1 << 10)
        static let mangaListDidRefresh = NotificationOptions(rawValue: 1 << 11)
        static let mangaRefresh: NotificationOptions = [.mangaListWillRefresh, .mangaListDidRefresh]

        static let all: NotificationOptions = [.anime, .manga, .synchronization, .animeRefresh, .mangaRefresh]
    }
    
    enum NotificationContent {
        case animeAdd(anime: UserAnime)
        case animeUpdate(anime: UserAnime)
        case animeDelete(anime: UserAnime)
        
        case mangaAdd(manga: UserManga)
        case mangaUpdate(manga: UserManga)
        case mangaDelete(manga: UserManga)
        
        case animeListSynchronized(original: AnimeList?, new: AnimeList)
        case mangaListSynchronized(original: MangaList?, new: MangaList)
        
        case animeListWillRefresh
        case animeListDidRefresh(new: AnimeList?)
        
        case mangaListWillRefresh
        case mangaListDidRefresh(new: MangaList?)
    }
    
    private class Observer {
        weak var observer: AnyObject?
        var block: (NotificationContent) -> Void
        var options: NotificationOptions
        
        init(observer: AnyObject, options: NotificationOptions, block: @escaping (NotificationContent) -> Void) {
            self.observer = observer
            self.options = options
            self.block = block
        }
    }
    
    private var generalObservers: [Observer] = []
}

extension UserDataObserving {
    func observe(from object: AnyObject, options: NotificationOptions, block: @escaping (NotificationContent) -> Void) {
        if let observer = generalObservers.first(where: { $0.observer === object }) {
            observer.options = NotificationOptions(rawValue: observer.options.rawValue | options.rawValue)
        }
        else {
            generalObservers.append(Observer(observer: object, options: options, block: block))
        }
    }
    
    func stopObserving(from object: AnyObject) {
        if let index = generalObservers.index(where: { $0.observer === object }) {
            generalObservers.remove(at: index)
        }
    }
    
    func disablingObservation(for object: AnyObject, block: () -> Void) {
        var disabledObserver: Observer? = nil
        
        if let index = generalObservers.index(where: { $0.observer === object }) {
            disabledObserver = generalObservers.remove(at: index)
        }
        
        block()
        
        if let observer = disabledObserver {
            generalObservers.append(observer)
        }
    }
    
    func notify(option: NotificationOptions, content: NotificationContent) {
        for observer in generalObservers {
            if observer.options.contains(option) {
                observer.block(content)
            }
        }
    }
}
