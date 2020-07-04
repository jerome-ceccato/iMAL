//
//  AiringNotificationsCenter.swift
//  iMAL
//
//  Created by Jerome Ceccato on 18/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit
import UserNotifications

class AiringNotificationsCenter: NSObject {
    static let shared = AiringNotificationsCenter()
    
    class func setup() {
        shared.listenForNotifications()
        Database.shared.handleAnimeAiringDataAvailableNotification(shared) {
            shared.refreshScheduledNotificationsIfNeeded()
        }
    }
    
    private var isRefreshingScheduledNotifications: Bool = false
    private var isRegisteredForAnimeNotifications: Bool = false
    
    let notificationsLimit: Int = 64
}

// Logs
private extension AiringNotificationsCenter {
    class func log(_ content: Any) {
        //print(content)
    }
}

extension AiringNotificationsCenter {
    func canUseNotifications() -> Bool {
        if #available(iOS 10.0, *) {
            return true
        } else {
            return false
        }
    }
    
    func authorizeNotifications(completion: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
        else {
            completion(false)
        }
    }
    
    func listenForNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    func refreshScheduledNotificationsIfNeeded(completion: (() -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            if !isRefreshingScheduledNotifications && Settings.airingDatesEnabled && Settings.airingNotificationsEnabled {
                if let airingData = Database.shared.airingAnime {
                    isRefreshingScheduledNotifications = true
                    
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        if settings.authorizationStatus == .authorized {
                            
                            CurrentUser.me.requireUserList(type: .anime, loadingDelegate: nil) {
                                if let animelist = CurrentUser.me.cachedAnimeList() {
                                    self.scheduleNotifications(data: airingData, list: animelist) {
                                        self.registerToAnimeNotificationsIfNeeded()
                                        self.isRefreshingScheduledNotifications = false
                                        DispatchQueue.main.async {
                                            completion?()
                                        }
                                    }
                                }
                                else {
                                    self.isRefreshingScheduledNotifications = false
                                    DispatchQueue.main.async { completion?() }
                                }
                            }
                        }
                        else {
                            self.isRefreshingScheduledNotifications = false
                            DispatchQueue.main.async { completion?() }
                        }
                    }
                    return
                }
            }
        }
        completion?()
    }
    
    func toggleNotifications(for anime: UserAnime, enabled: Bool) {
        if #available(iOS 10.0, *) {
            if enabled {
                addAnime(anime)
            }
            else {
                removeAnime(anime)
            }
        }
    }
    
    func cleanupScheduledNotifications(clearPending: Bool) {
        if #available(iOS 10.0, *) {
            if clearPending {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                cleanupImageStorage()
                unregisterToAnimeNotifications()
                AiringNotificationsCenter.log("Removing all notifications and image storage...")
            }
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    func cleanupImageCache() {
        if #available(iOS 10.0, *) {
            cleanupImageStorage()
        }
    }
}

// MARK: Delegate
@available(iOS 10.0, *)
extension AiringNotificationsCenter: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let link = userInfo["deeplink"] as? String, let url = URL(string: link) {
            DeeplinkManager.handle(url: url)
        }
        completionHandler()
    }
}

// MARK: Schedule classes
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    class NotificationRequest {
        var fireDate: Date
        var identifier: String
        var anime: Anime
        var request: UNNotificationRequest
        
        init(identifier: String, fireDate: Date, anime: Anime, request: UNNotificationRequest) {
            self.identifier = identifier
            self.fireDate = fireDate
            self.request = request
            self.anime = anime
        }
    }
}

// MARK: Schedule
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    func scheduleNotifications(data: AiringData, list: AnimeList, completion: @escaping () -> Void) {
        let notifications = prepareNotifications(for: data, list: list, limit: notificationsLimit)
        let center = UNUserNotificationCenter.current()
        
        center.removeAllDeliveredNotifications()
        
        center.getPendingNotificationRequests { requests in
            AiringNotificationsCenter.log("Currently have \(requests.count) notifications scheduled")
            var lookup = self.buildLookupTable(for: notifications)
            var toRemove: [UNNotificationRequest] = []
            requests.forEach { request in
                if lookup[request.identifier] != nil {
                    lookup.removeValue(forKey: request.identifier)
                }
                else {
                    toRemove.append(request)
                }
            }
            
            AiringNotificationsCenter.log("Removing \(toRemove.count) notifications...")
            center.removePendingNotificationRequests(withIdentifiers: toRemove.map { $0.identifier })
            let newNotifications = Array(lookup.values)
            
            AiringNotificationsCenter.log("Adding \(newNotifications.count) notifications...")
            newNotifications.forEach { request in
                center.add(request.request) { error in
                    if let error = error {
                        AiringNotificationsCenter.log("Error adding \(request.anime.name): \(error)")
                    }
                }
            }
            self.forceReAddRequestsWithImageIfNeeded(requests: newNotifications)
            
            completion()
        }
    }
    
    func forceReAddRequestsWithImageIfNeeded(requests: [NotificationRequest]) {
        let center = UNUserNotificationCenter.current()
        var animeLookup = animeLookupTable(from: requests)
        
        animeLookup.keys.forEach { identifier in
            let items = animeLookup[identifier]!
            if let anime = items.first?.anime {
                self.downloadImage(for: anime) { image in
                    if let image = image {
                        AiringNotificationsCenter.log("Downloaded image for \(anime.name)")
                        items.forEach { request in
                            if let newRequest = self.notificationRequestWithForcedDownloadedImage(with: request, image: image) {
                                AiringNotificationsCenter.log("Re-adding notification with image for \(request.anime.name)")
                                center.add(newRequest) { error in
                                    if let error = error {
                                        AiringNotificationsCenter.log("Error re-adding \(request.anime.name): \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func purgeNotifications(amount: Int, notifications: [UNNotificationRequest], newNotifications: [NotificationRequest]) -> [NotificationRequest] {
        AiringNotificationsCenter.log("Purging \(amount) notifications to avoid hitting limit...")
        
        var allNotifications = notifications
        allNotifications.append(contentsOf: newNotifications.map { $0.request })
        allNotifications.sort { a, b in
            let aDate = (a.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() ?? Date()
            let bDate = (b.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() ?? Date()
            
            return aDate < bDate
        }
        
        var toRemove = allNotifications.suffix(amount)
        let toAdd = newNotifications.filter { item in
            if let index = toRemove.index(of: item.request) {
                toRemove.remove(at: index)
                return false
            }
            return true
        }
        
        AiringNotificationsCenter.log("Effectively removing \(toRemove.count) notifications...")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: toRemove.map { $0.identifier })
        
        return toAdd
    }
    
    func buildLookupTable(for requests: [NotificationRequest]) -> [String: NotificationRequest] {
        var lookup: [String: NotificationRequest] = [:]
        requests.forEach { req in
            lookup[req.identifier] = req
        }
        return lookup
    }
    
    func prepareNotifications(for data: AiringData, list: AnimeList, limit: Int) -> [NotificationRequest] {
        let requests = buildNotifications(for: data, list: list).sorted { a, b in
            return a.fireDate < b.fireDate
        }
        
        return requests.count > limit ? Array(requests.prefix(limit)) : requests
    }
    
    func buildNotifications(for data: AiringData, list: AnimeList) -> [NotificationRequest] {
        var requests: [NotificationRequest] = []
        
        data.anime.forEach { airingAnime in
            if let userAnime = list.find(by: airingAnime.identifier) {
                let notifications = buildNotifications(for: airingAnime, userAnime: userAnime)
                requests.append(contentsOf: notifications)
            }
        }
        
        return requests
    }
    
    func animeLookupTable(from requests: [NotificationRequest]) -> [Int: [NotificationRequest]] {
        var animeLookup: [Int: [NotificationRequest]] = [:]
        
        requests.forEach { request in
            if request.request.content.attachments.isEmpty {
                if animeLookup[request.anime.identifier] == nil {
                    animeLookup[request.anime.identifier] = [request]
                }
                else {
                    animeLookup[request.anime.identifier]!.append(request)
                }
            }
        }
        return animeLookup
    }
}

// MARK: Building notifications
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    func buildNotifications(for airingAnime: AiringData.Anime, userAnime: UserAnime) -> [NotificationRequest] {
        if shouldScheduleNotifications(for: userAnime) {
            if Settings.airingNotificationsTrackWatchedOnly {
                if let nextEpisode = airingAnime.nextEpisode(), nextEpisode.number == userAnime.watchedEpisodes + 1 {
                    return [notificationRequest(for: nextEpisode, anime: userAnime.animeSeries)]
                }
            }
            else {
                let now = Date()
                var requests: [NotificationRequest] = []
                airingAnime.episodes.forEach { episode in
                    if episode.time > now {
                        requests.append(notificationRequest(for: episode, anime: userAnime.animeSeries))
                    }
                }
                return requests
            }
        }
        return []
    }
    
    func shouldScheduleNotifications(for anime: UserAnime) -> Bool {
        if !Settings.airingNotificationsIsAnimeEnabled(identifier: anime.animeSeries.identifier) {
            return false
        }
        
        switch Settings.airingNotificationStatusEnabled {
        case .watching:
            return anime.status == .watching
        case .watchingAndPTW:
            return [.watching, .planToWatch].contains(anime.status)
        case .all:
            return true
        }
    }
}

// MARK: Notifications content
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    func notificationRequestWithForcedDownloadedImage(with request: NotificationRequest, image: UIImage) -> UNNotificationRequest? {
        if let content = request.request.content.mutableCopy() as? UNMutableNotificationContent,
            let url = storeImage(image, for: request.identifier),
            let attachment = try? UNNotificationAttachment(identifier: request.identifier, url: url, options: nil) {
            
            content.attachments = [attachment]
            return UNNotificationRequest(identifier: request.request.identifier, content: content, trigger: request.request.trigger)
        }
        return nil
    }
    
    func notificationRequest(for episode: AiringData.Episode, anime: Anime) -> NotificationRequest {
        let airTime = notificationOffsetDate(date: episode.time)
        let identifier = notificationIdentifier(for: episode, anime: anime, airingTime: airTime)
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: airTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let content = mutableNotificationContent(for: episode, anime: anime)
        
       if let image = imageIfCached(for: anime) {
            if let url = storeImage(image, for: identifier),
                let attachment = try? UNNotificationAttachment(identifier: identifier, url: url, options: nil) {
                content.attachments = [attachment]
            }
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        return NotificationRequest(identifier: identifier, fireDate: airTime, anime: anime, request: request)
    }
    
    func mutableNotificationContent(for episode: AiringData.Episode, anime: Anime) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = anime.name
        content.body = "Ep. \(episode.number) has aired!"
        content.sound = UNNotificationSound.default()
        content.userInfo = ["deeplink": DeeplinkManager.listAnimeDeeplink(for: anime)]
        
        return content
    }
    
    func notificationOffsetDate(date: Date) -> Date {
        if Settings.airingNotificationsDoNotDisturbEnabled {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.calendar, .era, .year, .month, .weekOfYear, .day, .hour, .minute, .second, .timeZone], from: date)
            let from = Settings.airingNotificationDoNotDisturbFromTime, to = Settings.airingNotificationDoNotDisturbToTime
            
            // Same time - Skip
            if from.hour == to.hour && from.minute == to.minute {
                return date
            }
            // Ranging over 2 days
            else if from.hour > to.hour || (from.hour == to.hour && from.minute > to.minute) {
                // [from-X[
                if components.hour! > from.hour || (components.hour! == from.hour && components.minute! > from.minute) {
                    components.hour = to.hour
                    components.minute = to.minute
                    components.day = components.day! + 1
                    return calendar.date(from: components) ?? date
                }
                // ]X-to]
                else if components.hour! < to.hour || (components.hour! == to.hour && components.minute! < to.minute) {
                    components.hour = to.hour
                    components.minute = to.minute
                    return calendar.date(from: components) ?? date
                }
            }
            // Same day
            else {
                // [from-X-to]
                if (components.hour! > from.hour || (components.hour! == from.hour && components.minute! > from.minute))
                    && (components.hour! < to.hour || (components.hour! == to.hour && components.minute! < to.minute)) {
                    components.hour = to.hour
                    components.minute = to.minute
                    return calendar.date(from: components) ?? date
                }
            }
        }
        return date
    }
    
    func notificationIdentifier(for episode: AiringData.Episode, anime: Anime, airingTime: Date) -> String {
        return "\(anime.identifier)-\(episode.number)-\(floor(airingTime.timeIntervalSince1970))"
    }
    
    func imageIfCached(for anime: Anime) -> UIImage? {
        let cache = UIImageView.af_sharedImageDownloader.imageCache
        
        if let url = URL(string: anime.pictureURL) {
            return cache?.image(for: URLRequest(url: url), withIdentifier: nil)
        }
        return nil
    }
    
    func downloadImage(for anime: Anime, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: anime.pictureURL) {
            UIImageView.af_sharedImageDownloader.download(URLRequest(url: url), completion: { response in
                if let image = response.result.value {
                    completion(image)
                }
                else {
                    completion(nil)
                }
            })
        }
    }
}

// MARK: Image storage
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    func storageDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("notifs_thumb", isDirectory: true)
    }
    
    func storageImageURL(for identifier: String) -> URL? {
        let directory = storageDirectory()
        if (try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)) != nil {
            return directory.appendingPathComponent("\(identifier).png")
        }
        return nil
    }
    
    func cleanupImageStorage() {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: storageDirectory(), includingPropertiesForKeys: nil, options: [])
            try directoryContents.forEach(FileManager.default.removeItem(at:))
        }
        catch {}
    }
    
    @discardableResult
    func storeImage(_ image: UIImage, for identifier: String) -> URL? {
        if let url = storageImageURL(for: identifier) {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
            else if (try? UIImagePNGRepresentation(image)?.write(to: url, options: .atomic)) != nil {
                return url
            }
        }
        return nil
    }
}

// MARK: React to anime changes
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    func registerToAnimeNotificationsIfNeeded() {
        if !isRegisteredForAnimeNotifications {
            CurrentUser.me.observing.observe(from: self, options: .anime, block: { [weak self] content in
                switch content {
                case .animeAdd(let anime):
                    self?.addAnime(anime)
                case .animeUpdate(let anime):
                    self?.updateAnime(anime)
                case .animeDelete(let anime):
                    self?.removeAnime(anime)
                default:
                    break
                }
            })
            isRegisteredForAnimeNotifications = true
        }
    }
    
    func unregisterToAnimeNotifications() {
        if isRegisteredForAnimeNotifications {
            CurrentUser.me.observing.stopObserving(from: self)
            AiringNotificationsCenter.setup()
        }
    }
    
    func addAnime(_ anime: UserAnime, completion: (() -> Void)? = nil) {
        if Settings.airingDatesEnabled && Settings.airingNotificationsEnabled, let airingData = Database.shared.airingAnime {
            if let airing = airingData.findByID(anime.animeSeries.identifier) {
                let center = UNUserNotificationCenter.current()
                var notifs = self.buildNotifications(for: airing, userAnime: anime)
                if !notifs.isEmpty {
                    center.getPendingNotificationRequests { requests in
                        if requests.count + notifs.count > self.notificationsLimit {
                            notifs = self.purgeNotifications(amount: requests.count + notifs.count - self.notificationsLimit, notifications: requests, newNotifications: notifs)
                        }
                        
                        AiringNotificationsCenter.log("Adding \(notifs.count) notifications for new anime \(anime.animeSeries.name)")
                        notifs.forEach { notif in
                            UNUserNotificationCenter.current().add(notif.request) { error in
                                if let error = error {
                                    AiringNotificationsCenter.log("Error adding \(anime.animeSeries.name): \(error)")
                                }
                            }
                        }
                        self.forceReAddRequestsWithImageIfNeeded(requests: notifs)
                        completion?()
                    }
                    return
                }
            }
        }
        completion?()
    }
    
    func removeAnime(_ anime: UserAnime, completion: (() -> Void)? = nil) {
        if Settings.airingDatesEnabled && Settings.airingNotificationsEnabled, let airingData = Database.shared.airingAnime {
            if airingData.findByID(anime.animeSeries.identifier) != nil {
                let center = UNUserNotificationCenter.current()
                center.getPendingNotificationRequests { requests in
                    let toRemove = requests.filter { request in
                        return request.identifier.hasPrefix("\(anime.animeSeries.identifier)-")
                    }
                    
                    if !toRemove.isEmpty {
                        AiringNotificationsCenter.log("Removing \(toRemove.count) notifications for anime \(anime.animeSeries.name)")
                        center.removePendingNotificationRequests(withIdentifiers: toRemove.map { $0.identifier })
                    }
                    completion?()
                }
                return
            }
        }
        completion?()
    }
    
    func updateAnime(_ anime: UserAnime, completion: (() -> Void)? = nil) {
        removeAnime(anime) {
            self.addAnime(anime, completion: completion)
        }
    }
}

// MARK: - Stats
extension AiringNotificationsCenter {
    struct Stats {
        var numberOfAnime: Int
        var lastScheduledDate: Date?
        
        var scheduledNotifications: Int
        var notificationLimit: Int
    }
    
    func getStats(completion: @escaping (Stats) -> Void) {
        if #available(iOS 10.0, *) {
            computeStats(completion: { stats in DispatchQueue.main.async { completion(stats) } })
        }
    }
}

// MARK: Stats content
@available(iOS 10.0, *)
private extension AiringNotificationsCenter {
    struct RequestComponents {
        var identifier: Int
        var scheduled: Date
    }
    
    func computeStats(completion: @escaping (Stats) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let numberOfRequests = requests.count
            var anime: [Int: Bool] = [:]
            var lastSchedule: Date? = nil
            
            requests.forEach { request in
                if let comps = self.components(for: request) {
                    anime[comps.identifier] = true
                    if comps.scheduled > (lastSchedule ?? Date.distantPast) {
                        lastSchedule = comps.scheduled
                    }
                }
            }
            
            completion(Stats(numberOfAnime: anime.keys.count, lastScheduledDate: lastSchedule, scheduledNotifications: numberOfRequests, notificationLimit: self.notificationsLimit))
        }
    }
    
    func components(for request: UNNotificationRequest) -> RequestComponents? {
        let raw = request.identifier.components(separatedBy: "-")
        if raw.count == 3 {

            if let identifier = Int(raw[0]),
                let timestamp = TimeInterval(raw[2]) {
                let scheduled = Date(timeIntervalSince1970: timestamp)
                return RequestComponents(identifier: identifier, scheduled: scheduled)
            }
        }
        return nil
    }
}
