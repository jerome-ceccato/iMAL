//
//  UserDataCache.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

struct UserDataCache {
    struct UserData {
        var username: String
        var animeList: AnimeList?
        var mangaList: MangaList?
    }
    
    let type: EntityKind
    
    func path(for username: String) -> URL? {
        return UserDataCache.cachedListURL(type: type, username: username)
    }
    
    func cachedList<T: IndexableList & Codable>(for username: String) -> T? {
        do {
            if let fileURL = path(for: username) {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(T.self, from: data)
            }
        }
        catch {
            print(error)
        }
        return nil
    }
    
    func save<T: IndexableList & Codable>(list: T, for username: String) {
        UserDataCache.ensureBaseDirectoryExists()
        
        do {
            if let fileURL = path(for: username) {
                let data = try JSONEncoder().encode(list)
                try data.write(to: fileURL, options: .atomic)
            }
        }
        catch {
            print(error)
        }
    }

    static func clear() {
        do {
            if let url = cacheBaseDirectory {
                try FileManager.default.removeItem(at: url)
            }
        }
        catch {
            print(error)
        }
    }
    
    static func allCachedUsers() -> [String] {
        do {
            if let url = cacheBaseDirectory {
                let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                
                var users = Set<String>()
                files.forEach { url in
                    if url.pathExtension == "json" {
                        let prefix = "x-"
                        let filename = url.lastPathComponent
                        let basefilename = filename[..<filename.index(filename.endIndex, offsetBy: -(url.pathExtension.count + ".".count))]
                        let username = basefilename[basefilename.index(filename.startIndex, offsetBy: prefix.count)...]
                        
                        users.insert(String(username))
                    }
                }

                return Array(users)
            }
        }
        catch {
            print(error)
        }
        return []
    }
    
    static func allUserData() -> [UserData] {
        let usernames = allCachedUsers()
        let animeCache = UserDataCache(type: .anime)
        let mangaCache = UserDataCache(type: .manga)
        
        var users = [UserData]()
        usernames.forEach { name in
            let animeList: AnimeList? = animeCache.cachedList(for: name)
            let mangaList: MangaList? = mangaCache.cachedList(for: name)
            
            users.append(UserData(username: name, animeList: animeList, mangaList: mangaList))
        }
        return users
    }
}

private extension UserDataCache {
    static var cacheBaseDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("imal_list_cache")
    }
    
    static func purgeUsername(_ username: String) -> String {
        return username.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "_")
    }
    
    static func cachedListURL(type: EntityKind, username: String) -> URL? {
        return cacheBaseDirectory?.appendingPathComponent("\(type.shortIdentifier)-\(purgeUsername(username)).json")
    }
    
    static func ensureBaseDirectoryExists() {
        if let url = cacheBaseDirectory {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
