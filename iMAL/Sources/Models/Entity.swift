//
//  Entity.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol EntityStatus {
    var rawValue: Int { get }
    var displayString: String { get }
    var isDone: Bool { get }
}

protocol EntityType {
    var rawValue: Int { get }
    var displayString: String { get }
}

enum EntityRating: Int {
    case allAges = 1
    case children = 2
    case teens = 3
    case violence = 4
    case mildNudity = 5
    case hentai = 6
}

extension EntityRating {
    var shortSymbol: String {
        switch self {
        case .allAges:
            return "G"
        case .children:
            return "PG"
        case .teens:
            return "PG-13"
        case .violence:
            return "R"
        case .mildNudity:
            return "R+"
        case .hentai:
            return "Rx"
        }
    }
    
    var displayString: String {
        switch self {
        case .allAges:
            return "All ages"
        case .children:
            return "Children"
        case .teens:
            return "Teens 13 or older"
        case .violence:
            return "17+ (violence & profanity)"
        case .mildNudity:
            return "Mild nudity"
        case .hentai:
            return "Hentai"
        }
    }
}

class Entity: Codable {
    struct AlternativeTitles: Codable {
        var english: [String] = []
        var synonyms: [String] = []
        var japanese: [String] = []
    }
    
    struct Related: Codable {
        var section: String
        var items: [RelatedEntity]
    }
    
    var identifier: Int = 0
    
    var pictureURL: String = ""
    var name: String = ""
    var status: EntityStatus! = nil
    var type: EntityType! = nil
    
    var previewURL: String?
    var alternativeTitles = AlternativeTitles()
    
    var related: [Related] = []
    
    var rank: Int?
    var popularityRank: Int?
    var duration: Int?
    var startDate: Date?
    var endDate: Date?
    var classification: String?
    var membersScore: Float?
    var membersCount: Int?
    var favoritesCount: Int?
    
    var synopsis: String?
    var background: String?
    var genres: [String] = []
    
    var malURL: String {
        return ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case pictureURL
        case name
        case previewURL
        case alternativeTitles
        case related
        case rank
        case popularityRank
        case duration
        case startDate
        case endDate
        case classification
        case membersScore
        case membersCount
        case favoritesCount
        
        case synopsis
        case background
        case genres
    }
    
    init(json: JSON) {
        pictureURL = json["image_url"].stringValue
        name = json["title"].stringValue

        previewURL = json["preview"].string
        alternativeTitles.english = json["other_titles"]["english"].arrayValue.map { $0.stringValue }
        alternativeTitles.synonyms = json["other_titles"]["synonyms"].arrayValue.map { $0.stringValue }
        alternativeTitles.japanese = json["other_titles"]["japanese"].arrayValue.map { $0.stringValue }
        
        rank = json["rank"].int
        popularityRank = json["popularity_rank"].int
        duration = json["duration"].int
        startDate = json["start_date"].shortDate as Date?
        endDate = json["end_date"].shortDate as Date?
        classification = json["classification"].string
        membersScore = json["members_score"].float
        membersCount = json["members_count"].int
        favoritesCount = json["favorited_count"].int
        
        synopsis = json["synopsis"].string
        background = json["background"].string
        genres = json["genres"].arrayValue.map { $0.stringValue }
        
        related = json["related"].dictionaryValue.map({ (key: String, value: JSON) in
            Related(section: Entity.relatedDisplayName(key), items: value.arrayValue.map({ RelatedEntity(json: $0) }))
        }).sorted(by: { (a, b) in
            let apos = Entity.relatedSectionPosition(a.section)
            let bpos = Entity.relatedSectionPosition(b.section)
            
            if apos == bpos {
                return a.section < b.section
            }
            return apos < bpos
        })
    }

    var airingDatesDisplayString: String? {
        if let startDate = startDate {
            if let endDate = endDate {
                return "\(startDate.shortDateDisplayString) to \(endDate.shortDateDisplayString)"
            }
            return startDate.shortDateDisplayString
        }
        return nil
    }
    
    var durationDisplayString: String? {
        if let duration = duration {
            if duration >= 60 {
                return String(format: "%dh%02d", duration / 60, duration % 60)
            }
            return "\(duration) min"
        }
        return nil
    }
}

private extension Entity {
    class func relatedDisplayName(_ name: String) -> String {
        return name.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    class func relatedSectionPosition(_ name: String) -> Int {
        return ["Adaptation",
                "Prequel",
                "Sequel",
                "Related",
                "Side Story",
                "Parent Story",
                "Character",
                "Spin Off",
                "Summary",
                "Alternative Version"].index(of: name) ?? 999
    }
}
