//
//  DeeplinkManager.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class DeeplinkManager {
    private static var instance = DeeplinkManager()
    private var pendingDeeplink: URL?
    
    @discardableResult
    class func handle(url: URL, context: Any? = nil) -> Bool {
        if isDeepLink(url: url) {
            return instance.handleDeepLink(url, context: context)
        }
        return false
    }
    
    @discardableResult
    class func triggerPendingLink(context: Any?) -> Bool {
        if let url = instance.pendingDeeplink {
            instance.pendingDeeplink = nil
            return handle(url: url, context: context)
        }
        return false
    }
}

// MARK: - Creating
extension DeeplinkManager {
    class func mainURLScheme() -> String {
        return registeredURLSchemes().first ?? "imal"
    }
    
    class func listAnimeDeeplink(for anime: Anime) -> String {
        return "\(mainURLScheme())://animelist/\(anime.identifier)"
    }
}

// MARK: - Handling
private extension DeeplinkManager {
    class func registeredURLSchemes() -> [String] {
        var registeredSchemes = [String]()
        
        if let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject] {
            if let type = types.last as? [String: AnyObject] {
                if let schemes = type["CFBundleURLSchemes"] as? [AnyObject] {
                    for scheme in schemes {
                        if let string = scheme as? String {
                            registeredSchemes.append(string)
                        }
                    }
                }
            }
        }
        return registeredSchemes
    }
    
    class func isDeepLink(url: URL) -> Bool {
        return registeredURLSchemes().contains(url.scheme ?? "")
    }
    
    func linkComponents(url: URL) -> [String]? {
        if let scheme = url.scheme {
            let urlString = url.absoluteString
            let target = String(urlString[urlString.index(urlString.startIndex, offsetBy: (scheme + "://").count)...])
            let components = (target.components(separatedBy: "?").first ?? "").components(separatedBy: "/")
            if components.count > 0 {
                return components
            }
        }
        return nil
    }
    
    func handleDeepLink(_ url: URL, context: Any?) -> Bool {
        if CurrentUser.me.currentUsername.isEmpty {
            pendingDeeplink = url
            return false
        }
        
        if let target = linkComponents(url: url) {
            let mainTarget = target.first?.lowercased() ?? ""
            switch mainTarget {
            case "animelist":
                selectAnimeListTab()
                if target.count > 1 {
                    if let myAnimeList = (CustomTabBarController.shared?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? HomeAnimeListViewController, myAnimeList.canHandleDeeplink() {
                        if target.count > 1, let identifier = Int(target[1]) {
                            myAnimeList.forceSelectAnime(identifier: identifier)
                        }
                    }
                    else {
                        pendingDeeplink = url
                    }
                }
            default:
                return false
            }
            return true
        }
        return false
    }
}

// MARK: - Link handling
private extension DeeplinkManager {
    func selectAnimeListTab() {
        if let home = CustomTabBarController.shared {
            home.selectedIndex = 0
        }
    }
}

