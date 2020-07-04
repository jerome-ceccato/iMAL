//
//  CurrentUser.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

class CurrentUser {
    static var me: CurrentUser = CurrentUser()
    private init() {
        registerForCacheUpdating()
    }
    
    let observing = UserDataObserving()
    
    private static let keyUsername = "username"
    private static let keyPassword = "password"
    
    private(set) var animeList = UserManagedList<AnimeList>(type: .anime)
    private(set) var mangaList = UserManagedList<MangaList>(type: .manga)
    
    let memoryCacheDuration: TimeInterval = 3600 * 6
    
    private lazy var animeListSynchronizedLoadingTask: SynchronizedNetworkCall<AnimeList> = {
        return SynchronizedNetworkCall(action: { task, delegate in
            self.animeList.isSynchronizing = true
            return API.getAnimeList(username: self.currentUsername).request(loadingDelegate: delegate) { (success: Bool, animelist: AnimeList?) in
                self.animeList.isSynchronizing = false
                task.complete(success, animelist)
            }
        }, completion: { animelist in
            self.synchronize(animeList: animelist)
        })
    }()
    
    private lazy var mangaListSynchronizedLoadingTask: SynchronizedNetworkCall<MangaList> = {
        return SynchronizedNetworkCall(action: { task, delegate in
            self.mangaList.isSynchronizing = true
            return API.getMangaList(username: self.currentUsername).request(loadingDelegate: delegate) { (success: Bool, mangalist: MangaList?) in
                self.mangaList.isSynchronizing = false
                task.complete(success, mangalist)
            }
        }, completion: { mangalist in
            self.synchronize(mangaList: mangalist)
        })
    }()
}

// MARK: - Login
extension CurrentUser {
    var storedCredentials: NetworkManagerContext.Credentials? {
        get {
            if let username = UserDefaults.standard.string(forKey: CurrentUser.keyUsername),
                let password = UserDefaults.standard.string(forKey: CurrentUser.keyPassword) {
                return NetworkManagerContext.Credentials(username: username, password: password)
            }
            return nil
        }
        
        set {
            UserDefaults.standard.set(newValue?.username, forKey: CurrentUser.keyUsername)
            UserDefaults.standard.set(newValue?.password, forKey: CurrentUser.keyPassword)
            UserDefaults.standard.synchronize()
        }
    }
    
    var currentUsername: String {
        return UserDefaults.standard.string(forKey: CurrentUser.keyUsername) ?? ""
    }
    
    func logout() {
        storedCredentials?.password = ""
        UserDefaults.standard.removeObject(forKey: CurrentUser.keyPassword)
        UserDefaults.standard.synchronize()
        
        NetworkManagerContext.currentContext.credentials = nil
        clearUserLists()
        AiringNotificationsCenter.shared.cleanupScheduledNotifications(clearPending: true)
    }
}

// MARK: - Cache
extension CurrentUser {
    func cachedAnimeList() -> AnimeList? {
        return animeList.listOrCachedVersion()
    }
    
    func cachedMangaList() -> MangaList? {
        return mangaList.listOrCachedVersion()
    }
    
    private func synchronize(animeList: AnimeList?) {
        let originalList = self.animeList.list
        if let newList = animeList, self.animeList.synchronizeFromRemote(newList) {
            observing.notify(option: .animeListSynchronized, content: .animeListSynchronized(original: originalList, new: newList))
        }
    }
    
    private func synchronize(mangaList: MangaList?) {
        let originalList = self.mangaList.list
        if let newList = mangaList, self.mangaList.synchronizeFromRemote(newList) {
            observing.notify(option: .mangaListSynchronized, content: .mangaListSynchronized(original: originalList, new: newList))
        }
    }
}

// MARK: - Lists
extension CurrentUser {
    enum ReloadingOption: Int {
        case alwaysReload
        case reloadIfCached
        case neverReload
    }
    
    func loadAnimeList(option: ReloadingOption, loadingDelegate: NetworkLoading?, completion: @escaping (AnimeList?) -> Void) {
        guard !currentUsername.isEmpty else {
            completion(nil)
            return
        }
        
        if let animeList = cachedAnimeList(), option == .neverReload || (option == .reloadIfCached && self.animeList.synchronized) {
            completion(animeList)
        }
        else {
            if option == .alwaysReload {
                animeListSynchronizedLoadingTask.reset()
            }
            animeListSynchronizedLoadingTask.run(loadingDelegate: loadingDelegate, completion: {
                completion(self.animeList.list)
            })
        }
    }
    
    func loadMangaList(option: ReloadingOption, loadingDelegate: NetworkLoading?, completion: @escaping (MangaList?) -> Void) {
        guard !currentUsername.isEmpty else {
            completion(nil)
            return
        }
        
        if let mangaList = cachedMangaList(), option == .neverReload || (option == .reloadIfCached && self.mangaList.synchronized) {
            completion(mangaList)
        }
        else {
            if option == .alwaysReload {
                mangaListSynchronizedLoadingTask.reset()
            }
            mangaListSynchronizedLoadingTask.run(loadingDelegate: loadingDelegate, completion: {
                completion(self.mangaList.list)
            })
        }
    }
    
    func requireUserList(type: EntityKind, loadingDelegate: NetworkLoading?, completion: @escaping () -> Void) {
        guard !currentUsername.isEmpty else {
            completion()
            return
        }
        
        if type == .anime {
            if animeList.list != nil {
                completion()
            }
            else {
                animeListSynchronizedLoadingTask.run(loadingDelegate: loadingDelegate, completion: completion)
            }
        }
        else {
            if mangaList.list != nil {
                completion()
            }
            else {
                mangaListSynchronizedLoadingTask.run(loadingDelegate: loadingDelegate, completion: completion)
            }
        }
    }
    
    func clearUserLists() {
        animeList.clear()
        mangaList.clear()
        animeListSynchronizedLoadingTask.reset()
        mangaListSynchronizedLoadingTask.reset()
    }
}

// MARK: - List updating
extension CurrentUser {
    @discardableResult
    func updateEntity(_ entity: UserEntity) -> Bool {
        if let anime = entity as? UserAnime {
            return updateAnime(anime)
        }
        else if let manga = entity as? UserManga {
            return updateManga(manga)
        }
        return false
    }
    
    @discardableResult
    func addEntity(_ entity: UserEntity) -> Bool {
        if let anime = entity as? UserAnime {
            return addAnime(anime)
        }
        else if let manga = entity as? UserManga {
            return addManga(manga)
        }
        return false
    }
    
    @discardableResult
    func deleteEntity(_ entity: UserEntity) -> Bool {
        if let anime = entity as? UserAnime {
            return deleteAnime(anime)
        }
        else if let manga = entity as? UserManga {
            return deleteManga(manga)
        }
        return false
    }
    
    // - Anime
    
    @discardableResult
    func updateAnime(_ anime: UserAnime) -> Bool {
        if let animeList = animeList.list {
            for (index, oldAnime) in animeList.items.enumerated() {
                if oldAnime.series.identifier == anime.series.identifier {
                    animeList.items[index] = anime
                    animeList.updateSearchIndex(with: anime)
                    observing.notify(option: .animeUpdate, content: .animeUpdate(anime: anime))
                    return true
                }
            }
        }
        return false
    }
    
    @discardableResult
    func addAnime(_ anime: UserAnime) -> Bool {
        if !updateAnime(anime) {
            if let animeList = animeList.list {
                animeList.items.append(anime)
                animeList.updateSearchIndex(with: anime)
                observing.notify(option: .animeAdd, content: .animeAdd(anime: anime))
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func deleteAnime(_ anime: UserAnime) -> Bool {
        if let animeList = animeList.list {
            if let index = animeList.items.index(where: { $0.series.identifier == anime.series.identifier }) {
                animeList.items.remove(at: index)
                animeList.updateSearchIndex(with: anime, delete: true)
                observing.notify(option: .animeDelete, content: .animeDelete(anime: anime))
                return true
            }
        }
        return false
    }
    
    // -- Manga
    
    @discardableResult
    func updateManga(_ manga: UserManga) -> Bool {
        if let mangaList = mangaList.list {
            for (index, oldManga) in mangaList.items.enumerated() {
                if oldManga.series.identifier == manga.series.identifier {
                    mangaList.items[index] = manga
                    mangaList.updateSearchIndex(with: manga)
                    observing.notify(option: .mangaUpdate, content: .mangaUpdate(manga: manga))
                    return true
                }
            }
        }
        return false
    }
    
    @discardableResult
    func addManga(_ manga: UserManga) -> Bool {
        if !updateManga(manga) {
            if let mangaList = mangaList.list {
                mangaList.items.append(manga)
                mangaList.updateSearchIndex(with: manga)
                observing.notify(option: .mangaAdd, content: .mangaAdd(manga: manga))
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func deleteManga(_ manga: UserManga) -> Bool {
        if let mangaList = mangaList.list {
            if let index = mangaList.items.index(where: { $0.series.identifier == manga.series.identifier }) {
                mangaList.items.remove(at: index)
                mangaList.updateSearchIndex(with: manga, delete: true)
                observing.notify(option: .mangaDelete, content: .mangaDelete(manga: manga))
                return true
            }
        }
        return false
    }
}

// MARK: - Cache updating
private extension CurrentUser {
    func registerForCacheUpdating() {
        observing.observe(from: self, options: [.anime, .manga]) { [weak self] content in
            switch content {
            case .animeAdd(let anime):
                self?.handleAnimeUpdates(type: .add, anime: anime)
            case .animeUpdate(let anime):
                self?.handleAnimeUpdates(type: .update, anime: anime)
            case .animeDelete(let anime):
                self?.handleAnimeUpdates(type: .delete, anime: anime)

            case .mangaAdd(let manga):
                self?.handleMangaUpdates(type: .add, manga: manga)
            case .mangaUpdate(let manga):
                self?.handleMangaUpdates(type: .update, manga: manga)
            case .mangaDelete(let manga):
                self?.handleMangaUpdates(type: .delete, manga: manga)
            default:
                break
            }
        }
        
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(self.checkCacheValidity), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func checkCacheValidity() {
        let targetDate = Date(timeIntervalSinceNow: -memoryCacheDuration)
        
        if animeList.invalidateMemoryCache(ifPriorToDate: targetDate) {
            observing.notify(option: .animeListWillRefresh, content: .animeListWillRefresh)
            loadAnimeList(option: .alwaysReload, loadingDelegate: nil) { [weak self] list in
                self?.observing.notify(option: .animeListDidRefresh, content: .animeListDidRefresh(new: list))
            }
        }
        
        if mangaList.invalidateMemoryCache(ifPriorToDate: targetDate) {
            observing.notify(option: .mangaListWillRefresh, content: .mangaListWillRefresh)
            loadMangaList(option: .alwaysReload, loadingDelegate: nil) { [weak self] list in
                self?.observing.notify(option: .mangaListDidRefresh, content: .mangaListDidRefresh(new: list))
            }
        }
    }
    
    func handleAnimeUpdates(type: ListUpdateType, anime: UserAnime) {
        animeList.userDidUpdateList(type: type, entity: anime)
        animeList.synchronizeCache()
    }
    
    func handleMangaUpdates(type: ListUpdateType, manga: UserManga) {
        mangaList.userDidUpdateList(type: type, entity: manga)
        mangaList.synchronizeCache()
    }
}
