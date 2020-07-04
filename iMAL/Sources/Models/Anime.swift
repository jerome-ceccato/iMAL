//
//  Anime.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AnimeStatus: Int, Codable {
    case unknown
    case airing = 1
    case finishedAiring = 2
    case notYetAired = 3
}

extension AnimeStatus: EntityStatus {
    var displayString: String {
        switch self {
        case .airing:
            return "Airing"
        case .finishedAiring:
            return "Finished Airing"
        case .notYetAired:
            return "Not Yet Aired"
        default:
            return ""
        }
    }
    
    var isDone: Bool {
        return self == .finishedAiring
    }
    
    init(string: String) {
        switch string {
        case "currently airing":
            self = .airing
        case "finished airing":
            self = .finishedAiring
        case "not yet aired":
            self = .notYetAired
        default:
            self = .unknown
        }
    }
}

enum AnimeType: Int, Codable {
    case unknown
    case tv = 1
    case ova = 2
    case movie = 3
    case special = 4
    case ona = 5
    case music = 6
}

extension AnimeType : EntityType {
    var displayString: String {
        switch self {
        case .tv:
            return "TV"
        case .ova:
            return "OVA"
        case .movie:
            return "Movie"
        case .special:
            return "Special"
        case .ona:
            return "ONA"
        case .music:
            return "Music"
        default:
            return ""
        }
    }
    
    init(string: String) {
        switch string {
        case "TV":
            self = .tv
        case "OVA":
            self = .ova
        case "Movie":
            self = .movie
        case "Special":
            self = .special
        case "ONA":
            self = .ona
        case "Music":
            self = .music
        default:
            self = .unknown
        }
    }
}

class Anime: Entity {
    var episodes: Int = 0
    
    var openingThemes: [String] = []
    var endingThemes: [String] = []
    var recommendations: [Anime] = []
    
    var producers: [String] = []
    var licensors: [String] = []
    var studios: [String] = []
    
    var source: String? = nil
    
    var animeStatus: AnimeStatus! {
        return status as? AnimeStatus
    }
    
    var animeType: AnimeType! {
        return type as? AnimeType
    }
    
    override var malURL: String {
        return "https://myanimelist.net/anime/\(identifier)"
    }
    
    convenience init(related: RelatedEntity) {
        self.init(json: JSON(NSNull()))
        identifier = related.animeIdentifier ?? 0
        name = related.name
    }

    override init(json: JSON) {
        super.init(json: json)

        identifier = json["id"].int ?? json["anime_id"].intValue
        
        status = AnimeStatus(string: json["status"].stringValue)
        type = AnimeType(string: json["type"].stringValue)
        episodes = json["episodes"].intValue
        
        recommendations = json["recommendations"].arrayValue.map { Anime(json: $0) }
        openingThemes = json["opening_theme"].arrayValue.map { $0.stringValue }
        endingThemes = json["ending_theme"].arrayValue.map { $0.stringValue }
        
        producers = json["producers"].arrayValue.map { $0.stringValue }
        licensors = json["licensors"].arrayValue.map { $0.stringValue }
        studios = json["studios"].arrayValue.map { $0.stringValue }
        
        source = json["source"].string
    }
    
    private enum CodingKeys: String, CodingKey {
        case episodes
        case openingThemes
        case endingThemes
        case recommendations
        case producers
        case licensors
        case studios
        case source
        
        case status
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        episodes = try container.decode(Int.self, forKey: .episodes)
        openingThemes = try container.decode([String].self, forKey: .openingThemes)
        endingThemes = try container.decode([String].self, forKey: .endingThemes)
        recommendations = try container.decode([Anime].self, forKey: .recommendations)
        producers = try container.decode([String].self, forKey: .producers)
        licensors = try container.decode([String].self, forKey: .licensors)
        studios = try container.decode([String].self, forKey: .studios)
        source = try container.decode(String?.self, forKey: .source)
        
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
        
        status = try container.decode(AnimeStatus.self, forKey: .status)
        type = try container.decode(AnimeType.self, forKey: .type)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(episodes, forKey: .episodes)
        try container.encode(openingThemes, forKey: .openingThemes)
        try container.encode(endingThemes, forKey: .endingThemes)
        try container.encode(recommendations, forKey: .recommendations)
        try container.encode(producers, forKey: .producers)
        try container.encode(licensors, forKey: .licensors)
        try container.encode(studios, forKey: .studios)
        try container.encode(source, forKey: .source)
        
        try container.encode(animeStatus!, forKey: .status)
        try container.encode(animeType!, forKey: .type)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

extension Anime {
    static let genres: [String] = [
        "Action",
        "Adventure",
        "Cars",
        "Comedy",
        "Dementia",
        "Demons",
        "Mystery",
        "Drama",
        "Ecchi",
        "Fantasy",
        "Game",
        "Hentai",
        "Historical",
        "Horror",
        "Kids",
        "Magic",
        "Martial Arts",
        "Mecha",
        "Music",
        "Parody",
        "Samurai",
        "Romance",
        "School",
        "Sci-Fi",
        "Shoujo",
        "Shoujo Ai",
        "Shounen",
        "Shounen Ai",
        "Space",
        "Sports",
        "Super Power",
        "Vampire",
        "Yaoi",
        "Yuri",
        "Harem",
        "Slice of Life",
        "Supernatural",
        "Military",
        "Police",
        "Psychological",
        "Thriller",
        "Seinen",
        "Josei"
    ]
}
