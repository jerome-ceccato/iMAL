//
//  AiringData.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 16/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class AiringData {
    var anime: [AiringData.Anime] = []
    var lastUpdate: Date = Date()
    private var searchIndex: [Int: AiringData.Anime] = [:]
    
    init(json: JSON) {
        anime = json.arrayValue.map { AiringData.Anime(json: $0) }
        lastUpdate = Date()
        
        anime.forEach { item in
            searchIndex[item.identifier] = item
        }
    }
}

extension AiringData {
    class Anime {
        var identifier: Int
        var episodes: [AiringData.Episode]
        
        init(json: JSON) {
            identifier = json["mal_id"].intValue
            episodes = json["airing"].arrayValue.compactMap { AiringData.Episode(timestamp: $0["t"].intValue, number: $0["n"].intValue) }
        }
    }

    class Episode {
        var jptime: Date
        var number: Int
        
        var time: Date {
            if let offset = Settings.airingTimeOffset {
                let components = DateComponents(calendar: Calendar.current, day: offset.days, hour: offset.hours, minute: offset.minutes)
                return Calendar.current.date(byAdding: components, to: jptime) ?? jptime
            }
            return jptime
        }
        
        init?(timestamp: Int, number: Int) {
            if timestamp == 0 || number == 0 {
                return nil
            }
            
            self.jptime = Date(timeIntervalSince1970: TimeInterval(timestamp))
            self.number = number
        }
    }
}

extension AiringData {    
    func findByID(_ identifier: Int) -> AiringData.Anime? {
        return searchIndex[identifier]
    }
}

extension AiringData.Anime {
    func nextEpisode(after: Date = Date()) -> AiringData.Episode? {
        return episodes.find { $0.time > after }
    }
}

extension AiringData.Episode {
    enum DisplayStringContext {
        case standalone
        case needsSeparator
    }
    
    func localTimeDisplayString(context: DisplayStringContext = .standalone) -> String {
        let calendar = Calendar.current
        let now = Date()
        let localTime = time
        
        if (calendar.dateComponents([.day], from: now, to: localTime).day ?? 0) >= 10 {
            let leading = context == .standalone ? "" : "- "
            return leading + SharedFormatters.mediumDateDisplayFormatter.string(from: localTime)
        }
        else if calendar.isDateInToday(localTime) {
            return "\(SharedFormatters.todayDisplayFormatter.string(from: localTime)) \(SharedFormatters.shortTimeDisplayFormatter.string(from: localTime))"
        }
        else {
            let components = calendar.dateComponents([.day, .hour], from: now, to: localTime)
            return "in \(SharedFormatters.relativeTimeDisplayFormatter.string(from: components) ?? "?")"
        }
    }
    
    func airingTimeDisplayString(useDate: Bool) -> String {
        let localTime = time
        if useDate {
            return SharedFormatters.mediumDateDisplayFormatter.string(from: localTime)
        }
        else {
            return SharedFormatters.shortTimeDisplayFormatter.string(from: localTime)
        }
    }
}

extension AiringData {
    struct Offset {
        var days: Int = 0
        var hours: Int = 0
        var minutes: Int = 0
        
        init() {}
        init(raw: [Int]) {
            days = raw[0]
            hours = raw[1]
            minutes = raw[2]
        }
        
        func pack() -> [Int] {
            return [days, hours, minutes]
        }
        
        var displayString: String? {
            if days == 0 && hours == 0 && minutes == 0 {
                return nil
            }
            
            let append = { (content: String, value: Int, name: String) -> String in
                if value > 0 {
                    return content.isEmpty ? "\(value)\(name)" : "\(content) \(value)\(name)"
                }
                return content
            }
            
            return append(append(append("", days, "d"), hours, "h"), minutes, "m")
        }
    }
}
