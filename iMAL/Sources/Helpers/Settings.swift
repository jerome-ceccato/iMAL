//
//  Settings.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class Settings {
    private init() {}
    
    private static var airingNotificationAnimeLookupTable: [Int: Bool]?
}

// MARK: - Themes
extension Settings {
    enum Theme: String {
        case `default` = "default"
        case light = "light"
    }
    
    private static let themeKey = "imal-theme"
  
    static var theme: Theme {
        get {
            return getString(themeKey).flatMap { Theme(rawValue: $0) } ?? .default
        }
        set {
            setString(newValue.rawValue, key: themeKey)
        }
    }
}

extension Settings.Theme {
    var displayString: String {
        switch self {
        case .default:
            return "Default dark"
        case .light:
            return "Light"
        }
    }
    
    static private let allOptions: [Settings.Theme] = [.default, .light]
    
    static var availableOptionsStrings: [String] {
        return allOptions.map { $0.rawValue }
    }
    
    static var availableOptionsDisplayStrings: [String] {
        return allOptions.map { $0.displayString }
    }
    
    var appIconFilename: String? {
        switch self {
        case .default:
            return nil
        case .light:
            return "AppIcon-light"
        }
    }
}



// MARK: - Cache Control
extension Settings {
    private static let preventEditingUntilSynchedKey = "imal-lock-editing-sync"
    
    static var preventEditingUntilSynched: Bool {
        get {
            return getBool(preventEditingUntilSynchedKey) ?? true
        }
        set {
            setBool(newValue, key: preventEditingUntilSynchedKey)
        }
    }
}

// MARK: - UI
extension Settings {
    enum Orientation: Int {
        case device
        case portait
        case landscape
    }
    
    private static let listIncrementDelayKey = "imal-list-increment-delay"
    private static let orientationLockKey = "imal-orientation-lock"
    private static let preferedVALanguageKey = "imal-prefered-va-language"
    
    static var listIncrementDelay: TimeInterval {
        get {
            return getDouble(listIncrementDelayKey) ?? 0.5
        }
        set {
            setDouble(newValue, key: listIncrementDelayKey)
        }
    }
    
    static var orientationPreference: Orientation {
        get {
            return getInt(orientationLockKey).flatMap { Orientation(rawValue: $0) } ?? .device
        }
        set {
            setInt(newValue.rawValue, key: orientationLockKey)
        }
    }
    
    static var preferedVoiceActorLanguage: String? {
        get {
            return getString(preferedVALanguageKey)
        }
        set {
            setString(newValue, key: preferedVALanguageKey)
        }
    }
}

extension Settings.Orientation {
    var displayString: String {
        switch self {
        case .device:
            return "Automatic"
        case .portait:
            return "Portrait"
        case .landscape:
            return "Landscape"
        }
    }
    
    static var availableOptionsDisplayStrings: [String] {
        let options: [Settings.Orientation] = [.device, .portait, .landscape]
        return options.map { $0.displayString }
    }
}


// MARK: - List
extension Settings {
    private static let listsStyleKey = "imal-lists-style"
    private static let enableAutomaticDatesKey = "imal-automatic-dates"
    
    private static var defaultListStyle: ListDisplayStyle {
        return UIDevice.current.isiPad() ? ListDisplayStyle.collectionViewDefault : ListDisplayStyle.tableViewDefault
    }
    
    static var listsStyle: ListDisplayStyle {
        get {
            return ListDisplayStyle(rawValue: getInt(listsStyleKey) ?? defaultListStyle.rawValue) ?? defaultListStyle
        }
        set {
            setInt(newValue.rawValue, key: listsStyleKey)
        }
    }
    
    static var enableAutomaticDates: Bool {
        get {
            return getBool(enableAutomaticDatesKey) ?? true
        }
        set {
            setBool(newValue, key: enableAutomaticDatesKey)
        }
    }
}


// MARK: - Airing
extension Settings {
    private static let airingDatesEnabledKey = "imal-airing-dates-enabled"
    private static let airingTimeOffsetKey = "imal-airing-dates-offset"
    
    static var airingDatesEnabled: Bool {
        get {
            return getBool(airingDatesEnabledKey) ?? true
        }
        set {
            setBool(newValue, key: airingDatesEnabledKey)
        }
    }
    
    static var airingTimeOffset: AiringData.Offset? {
        get {
            if let raw = getObject(airingTimeOffsetKey) as? [Int] {
                return AiringData.Offset(raw: raw)
            }
            return nil
        }
        set {
            setObject(newValue?.pack() as AnyObject?, key: airingTimeOffsetKey)
        }
    }
}

// MARK: - Airing notifications
extension Settings {
    enum StatusEnabled: Int {
        case watching = 0
        case watchingAndPTW = 1
        case all = 2
    }
    
    private static let airingNotificationsEnabledKey = "imal-airing-notifs-enabled"
    private static let airingNotificationsStatusKey = "imal-airing-notifs-status"
    private static let airingNotificationsTrackWatchedOnlyKey = "imal-airing-notifs-track-watched-only"
    
    private static let airingNotificationsDisabledAnimeKey = "imal-airing-notifs-disabled-anime"
    
    private static let airingNotificationsDoNotDisturbEnabledKey = "imal-airing-notifs-dnd-enabled"
    private static let airingNotificationsDoNotDisturbFromKey = "imal-airing-notifs-dnd-from"
    private static let airingNotificationsDoNotDisturbToKey = "imal-airing-notifs-dnd-to"
    
    static var airingNotificationsEnabled: Bool {
        get {
            return getBool(airingNotificationsEnabledKey) ?? false
        }
        set {
            setBool(newValue, key: airingNotificationsEnabledKey)
        }
    }
    
    static var airingNotificationStatusEnabled: StatusEnabled {
        get {
            return StatusEnabled(rawValue: getInt(airingNotificationsStatusKey) ?? 0) ?? .watching
        }
        set {
            setInt(newValue.rawValue, key: airingNotificationsStatusKey)
        }
    }
    
    static var airingNotificationsTrackWatchedOnly: Bool {
        get {
            return getBool(airingNotificationsTrackWatchedOnlyKey) ?? false
        }
        set {
            setBool(newValue, key: airingNotificationsTrackWatchedOnlyKey)
        }
    }
    
    // MARK: - 
    
    private static var airingNotificationsAnimeDisabledTable: [Int: Bool] {
        get {
            if let table = airingNotificationAnimeLookupTable {
                return table
            }
            
            let array = getArray(airingNotificationsDisabledAnimeKey)?.compactMap { Int($0) } ?? []
            airingNotificationAnimeLookupTable = [:]
            array.forEach { airingNotificationAnimeLookupTable![$0] = true }
            return airingNotificationAnimeLookupTable!
        }
        
        set {
            airingNotificationAnimeLookupTable = newValue
            
            let array = newValue.compactMap { $0.value ? "\($0.key)" : nil }
            setArray(array, key: airingNotificationsDisabledAnimeKey)
        }
    }
    
    static func cleanupAiringNotificationsDisabledAnimeTable(with animelist: AnimeList) {
        var table = airingNotificationsAnimeDisabledTable
        
        Array(table.keys).forEach { identifier in
            if animelist.find(by: identifier) == nil {
                table.removeValue(forKey: identifier)
            }
        }
        airingNotificationsAnimeDisabledTable = table
    }
    
    static func airingNotificationsIsAnimeEnabled(identifier: Int) -> Bool {
        return !(airingNotificationsAnimeDisabledTable[identifier] ?? false)
    }
    
    static func airingNotificationsDisableAnime(identifier: Int, enabled: Bool) {
        airingNotificationsAnimeDisabledTable[identifier] = !enabled
    }
    
    // MARK: -
    
    struct Time {
        var hour: Int = 0
        var minute: Int = 0
        
        init(hour: Int = 0, minute: Int = 0) {
            self.hour = hour
            self.minute = minute
        }
        
        init(components: DateComponents) {
            hour = components.hour ?? 0
            minute = components.minute ?? 0
        }
        
        init?(raw: String?) {
            if let split = raw?.components(separatedBy: "-"), let hour = Int(split[0]), let minute = Int(split[1]) {
                self.hour = hour
                self.minute = minute
            }
            else {
                return nil
            }
        }
        
        func pack() -> String {
            return "\(hour)-\(minute)"
        }
        
        func toDateComponents() -> DateComponents {
            return DateComponents(hour: hour, minute: minute)
        }
        
        func shortDisplayString() -> String {
            let formatter = SharedFormatters.shortTimeDisplayFormatter
            return Calendar.current.date(from: toDateComponents()).map { formatter.string(from: $0) } ?? ""
        }
    }
    
    static var airingNotificationsDoNotDisturbEnabled: Bool {
        get {
            return getBool(airingNotificationsDoNotDisturbEnabledKey) ?? false
        }
        set {
            setBool(newValue, key: airingNotificationsDoNotDisturbEnabledKey)
        }
    }
    
    static var airingNotificationDoNotDisturbFromTime: Time {
        get {
            return Time(raw: getString(airingNotificationsDoNotDisturbFromKey)) ?? Time(hour: 22, minute: 0)
        }
        set {
            setString(newValue.pack(), key: airingNotificationsDoNotDisturbFromKey)
        }
    }
    
    static var airingNotificationDoNotDisturbToTime: Time {
        get {
            return Time(raw: getString(airingNotificationsDoNotDisturbToKey)) ?? Time(hour: 8, minute: 0)
        }
        set {
            setString(newValue.pack(), key: airingNotificationsDoNotDisturbToKey)
        }
    }
}


// MARK: - Twitter
extension Settings {
    private static let twitterEnabledKey = "imal-settings-twitter-enabled"
    private static let twitterSettingsKey = "imal-settings-twitter-settings"
    
    enum TwitterAction: Int {
        case addAnime = 0
        case updateAnime = 1
        case completeAnime = 2
        case dropAnime = 3
        
        case addManga = 4
        case updateManga = 5
        case completeManga = 6
        case dropManga = 7
    }
    
    static var twitterEnabled: Bool {
        get {
            return getBool(twitterEnabledKey) ?? false
        }
        set {
            setBool(newValue, key: twitterEnabledKey)
        }
    }
    
    static var twitterActionsEnabled: [TwitterAction: Bool] {
        get {
            if let raw = getString(twitterSettingsKey) {
                return unpack(raw, value: { TwitterAction(rawValue: Int($0)!)! })
            }
            return [.addAnime: true,
                    .updateAnime: true,
                    .completeAnime: true,
                    .dropAnime: true,
                    .addManga: true,
                    .updateManga: true,
                    .completeManga: true,
                    .dropManga: true]
        }
        set {
            let raw = pack(newValue, value: { $0.rawValue as AnyObject })
            setString(raw, key: twitterSettingsKey)
        }
    }}

// MARK: - Gestures
extension Settings {
    private static let pinchToCollapseKey = "imal-settings-gesture-pinch-collapse"
    private static let invertTapGesturesOnMyListKey = "imal-settings-gesture-invert-tap"
    private static let invertTapGesturesOnOthersKey = "imal-settings-gesture-invert-tap-others"
    
    static var pinchToCollapseEnabled: Bool {
        get {
            return getBool(pinchToCollapseKey) ?? true
        }
        set {
            setBool(newValue, key: pinchToCollapseKey)
        }
    }
    
    static var invertTapGesturesOnMyList: Bool {
        get {
            return getBool(invertTapGesturesOnMyListKey) ?? false
        }
        set {
            setBool(newValue, key: invertTapGesturesOnMyListKey)
        }
    }
    
    static var invertTapGesturesOnOthers: Bool {
        get {
            return getBool(invertTapGesturesOnOthersKey) ?? true
        }
        set {
            setBool(newValue, key: invertTapGesturesOnOthersKey)
        }
    }
}


// MARK: - Content
extension Settings {
    private static let rxfilterKey = "imal-settings-filter-rx"
    private static let mangaPreferredMetricKey = "imal-settings-manga-metric"
    
    static var filterRatedX: Bool {
        get {
            return getBool(rxfilterKey) ?? true
        }
        set {
            setBool(newValue, key: rxfilterKey)
        }
    }
    
    enum MangaMetric: Int {
        case dynamic = 0
        case volumes = 1
        case chapters = 2
    }
    
    static var preferredMangaMetric: MangaMetric {
        get {
            return getInt(mangaPreferredMetricKey).flatMap({ MangaMetric(rawValue: $0) }) ?? .dynamic
        }
        set {
            setInt(newValue.rawValue, key: mangaPreferredMetricKey)
        }
    }
}

extension Settings.MangaMetric {
    var displayString: String {
        switch self {
        case .dynamic:
            return "Automatic"
        case .volumes:
            return "Volumes"
        case .chapters:
            return "Chapters"
        }
    }
    
    static var availableOptionsDisplayStrings: [String] {
        let options: [Settings.MangaMetric] = [.dynamic, .volumes, .chapters]
        return options.map { $0.displayString }
    }
}

// MARK: - List sorting options
extension Settings {
    private static let animeListGroupingKey = "imal-anime-grouping"
    private static let animeListSortingKey = "imal-anime-sorting"
    private static let mangaListGroupingKey = "imal-manga-grouping"
    private static let mangaListSortingKey = "imal-manga-sorting"
    
    static var animeListSortingOptions: EntityListSorting {
        get {
            return EntityListSorting(
                grouping: EntityListSorting.GroupingOptions(rawValue: getInt(animeListGroupingKey) ?? 0) ?? .status,
                sorting: EntityListSorting.SortingOptions(rawValue: getInt(animeListSortingKey) ?? 0) ?? .alphabetically)
        }
        set {
            setInt(newValue.grouping.rawValue, key: animeListGroupingKey)
            setInt(newValue.sorting.rawValue, key: animeListSortingKey)
        }
    }
    
    static var mangaListSortingOptions: EntityListSorting {
        get {
            return EntityListSorting(
                grouping: EntityListSorting.GroupingOptions(rawValue: getInt(mangaListGroupingKey) ?? 0) ?? .status,
                sorting: EntityListSorting.SortingOptions(rawValue: getInt(mangaListSortingKey) ?? 0) ?? .alphabetically)
        }
        set {
            setInt(newValue.grouping.rawValue, key: mangaListGroupingKey)
            setInt(newValue.sorting.rawValue, key: mangaListSortingKey)
        }
    }
}

// MARK: - Home page active
extension Settings {
    enum HomePage: Int {
        case last = 0
        case anime = 1
        case manga = 2
    }
    
    private static let homePageControllerKey = "imal-settings-homepage"
    private static let lastActiveControllerKey = "imal-settings-last-active-controller"
    
    static var homePageController: HomePage {
        get {
            return HomePage(rawValue: getInt(homePageControllerKey) ?? 0) ?? .last
        }
        set {
            setInt(newValue.rawValue, key: homePageControllerKey)
        }
    }
    
    static var lastActiveController: HomePage {
        get {
            return HomePage(rawValue: getInt(lastActiveControllerKey) ?? 1) ?? .anime
        }
        set {
            setInt(newValue.rawValue, key: lastActiveControllerKey)
        }
    }
}

extension Settings.HomePage {
    var displayString: String {
        switch self {
        case .last:
            return "Last active"
        case .anime:
            return "My Anime List"
        case .manga:
            return "My Manga List"
        }
    }
    
    static var availableOptionsDisplayStrings: [String] {
        let options: [Settings.HomePage] = [.last, .anime, .manga]
        return options.map { $0.displayString }
    }
}

// MARK: - List expand options
extension Settings {
    enum ExpandOptions: Int {
        case save = 0
        case watchingOnly = 1
        case open = 2
        case closed = 3
    }
    
    static var animeListSectionsExpandOptions: ExpandOptions {
        get {
            return ExpandOptions(rawValue: getInt(animeSectionExpandOptionsKey) ?? 0) ?? .save
        }
        set {
            setInt(newValue.rawValue, key: animeSectionExpandOptionsKey)
            broadcastAnimeExpandOptionsNotification()
        }
    }
    
    static var mangaListSectionsExpandOptions: ExpandOptions {
        get {
            return ExpandOptions(rawValue: getInt(mangaSectionExpandOptionsKey) ?? 0) ?? .save
        }
        set {
            setInt(newValue.rawValue, key: mangaSectionExpandOptionsKey)
            broadcastMangaExpandOptionsNotification()
        }
    }
    
    static var animeStatusSectionState: [EntityUserStatus: Bool] {
        get {
            return storedSectionStateWithOptions(animeListSectionsExpandOptions, stored: storedAnimeStatusSectionState)
        }
        set {
            storedAnimeStatusSectionState = newValue
        }
    }
    
    static var mangaStatusSectionState: [EntityUserStatus: Bool] {
        get {
            return storedSectionStateWithOptions(mangaListSectionsExpandOptions, stored: storedMangaStatusSectionState)
        }
        set {
            storedMangaStatusSectionState = newValue
        }
    }
    
    static var searchSectionState: [Int: Bool] {
        get {
            return storedSearchSectionState
        }
        set {
            storedSearchSectionState = newValue
        }
    }
    
    private static let animeExpandUpdateNotification = "imal-anime-settings-expand"
    private static let mangaExpandUpdateNotification = "imal-manga-settings-expand"
    
    class func handleAnimeExpandOptionsUpdatedNotification(_ object: AnyObject, update: @escaping () -> Void) {
        NotificationCenter.register(object, animeExpandUpdateNotification, block: { notif in
            update()
        })
    }
    
    class func handleMangaExpandOptionsUpdatedNotification(_ object: AnyObject, update: @escaping () -> Void) {
        NotificationCenter.register(object, mangaExpandUpdateNotification, block: { notif in
            update()
        })
    }
    
    private class func broadcastAnimeExpandOptionsNotification() {
        Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: animeExpandUpdateNotification), object: nil)
    }
    
    private class func broadcastMangaExpandOptionsNotification() {
        Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: mangaExpandUpdateNotification), object: nil)
    }
}

extension Settings.ExpandOptions {
    var displayString: String {
        switch self {
        case .save:
            return "Save State"
        case .watchingOnly:
            return "Watching only"
        case .open:
            return "All Open"
        case .closed:
            return "All Closed"
        }
    }
    
    static func availableOptionsDisplayStrings(manga: Bool = false) -> [String] {
        let options: [Settings.ExpandOptions] = [.save, .watchingOnly, .open, .closed]
        if manga {
            return options.map { $0.displayString.replacingOccurrences(of: "Watching", with: "Reading") }
        }
        return options.map { $0.displayString }
    }
}

// MARK: - Utils
private extension Settings {
    class func getObject(_ key: String) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key) as AnyObject?
    }
    
    class func setObject(_ value: AnyObject?, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getString(_ key: String) -> String? {
        return UserDefaults.standard.object(forKey: key) as? String
    }
    
    class func setString(_ value: String?, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getInt(_ key: String) -> Int? {
        if UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.integer(forKey: key)
        }
        return nil
    }
    
    class func setInt(_ value: Int?, key: String) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key)
        }
        else {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    class func getDouble(_ key: String) -> Double? {
        if UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.double(forKey: key)
        }
        return nil
    }
    
    class func setDouble(_ value: Double?, key: String) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key)
        }
        else {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }

    class func getBool(_ key: String) -> Bool? {
        return UserDefaults.standard.object(forKey: key) != nil ? UserDefaults.standard.bool(forKey: key) : nil
    }
    
    class func setBool(_ value: Bool?, key: String) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key)
        }
        else {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    class func getArray(_ key: String) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key)
    }
    
    class func setArray(_ value: [String]?, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

}

// MARK: - List expand options
private extension Settings {
    static let animeSectionExpandOptionsKey = "imal-settings-anime-sections-expand"
    static let mangaSectionExpandOptionsKey = "imal-settings-manga-sections-expand"
    
    static let animeStatusSectionStateKey = "imal-settings-anime-sections-state"
    static let mangaStatusSectionStateKey = "imal-settings-manga-sections-state"
    static let searchSectionStateKey = "imal-settings-search-state"
    
    class func pack<T>(_ items: [T: Bool], value: (T) -> AnyObject) -> String {
        return items.reduce("", { (obj, keyVal) in
            "\((obj.isEmpty ? obj : "\(obj) "))\(value(keyVal.0)):\(keyVal.1)"
        })
    }
    
    class func unpack<T>(_ raw: String, value: (String) -> T) -> [T: Bool] {
        var ret = [T: Bool]()
        raw.components(separatedBy: " ").forEach { str in
            let values = str.components(separatedBy: ":")
            ret[value(values[0])] = values[1].toBool()!
        }
        return ret
    }
    
    class func storedSectionStateWithOptions(_ options: ExpandOptions, stored: [EntityUserStatus: Bool]) -> [EntityUserStatus: Bool] {
        switch options {
        case .save:
            return stored
        case .watchingOnly:
            return [.watching: true,
                    .completed: false,
                    .dropped: false,
                    .onHold: false,
                    .planToWatch: false]
        case .open:
            return [.watching: true,
                    .completed: true,
                    .dropped: true,
                    .onHold: true,
                    .planToWatch: true]
        case .closed:
            return [.watching: false,
                    .completed: false,
                    .dropped: false,
                    .onHold: false,
                    .planToWatch: false]
        }
    }
    
    static var storedAnimeStatusSectionState: [EntityUserStatus: Bool] {
        get {
            if let raw = getString(animeStatusSectionStateKey) {
                return unpack(raw, value: { EntityUserStatus(rawValue: Int($0)!)! })
            }
            return [.watching: true,
                    .completed: false,
                    .dropped: false,
                    .onHold: false,
                    .planToWatch: false]
        }
        set {
            let raw = pack(newValue, value: { $0.rawValue as AnyObject })
            setString(raw, key: animeStatusSectionStateKey)
        }
    }
    
    static var storedMangaStatusSectionState: [EntityUserStatus: Bool] {
        get {
            if let raw = getString(mangaStatusSectionStateKey) {
                return unpack(raw, value: { EntityUserStatus(rawValue: Int($0)!)! })
            }
            return [.watching: true,
                    .completed: false,
                    .dropped: false,
                    .onHold: false,
                    .planToWatch: false]
        }
        set {
            let raw = pack(newValue, value: { $0.rawValue as AnyObject })
            setString(raw, key: mangaStatusSectionStateKey)
        }
    }
    
    static var storedSearchSectionState: [Int: Bool] {
        get {
            if let raw = getString(searchSectionStateKey) {
                return unpack(raw, value: { Int($0)! })
            }
            return [0: true, 1: true]
        }
        set {
            let raw = pack(newValue, value: { $0 as AnyObject })
            setString(raw, key: searchSectionStateKey)
        }
    }
}
