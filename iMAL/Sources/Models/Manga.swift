//
//  Manga.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MangaStatus: Int, Codable {
    case unknown
    case publishing = 1
    case finished = 2
    case notYetPublished = 3
}

extension MangaStatus: EntityStatus {
    var displayString: String {
        switch self {
        case .publishing:
            return "Publishing"
        case .finished:
            return "Finished publishing"
        case .notYetPublished:
            return "Not Yet Published"
        default:
            return ""
        }
    }
    
    var isDone: Bool {
        return self == .finished
    }
    
    init(string: String) {
        switch string {
        case "publishing":
            self = .publishing
        case "finished":
            self = .finished
        case "not yet published":
            self = .notYetPublished
        default:
            self = .unknown
        }
    }
}

enum MangaType: Int, Codable {
    case unknown
    case manga = 1
    case novel = 2
    case oneShot = 3
    case doujin = 4
    case manhwa = 5
    case manhua = 6
    case oel = 7
}

extension MangaType : EntityType {
    var displayString: String {
        switch self {
        case .manga:
            return "Manga"
        case .novel:
            return "Novel"
        case .oneShot:
            return "One Shot"
        case .doujin:
            return "Doujin"
        case .manhwa:
            return "Manhwa"
        case .manhua:
            return "Manhua"
        case .oel:
            return "OEL"
        default:
            return ""
        }
    }
    
    init(string: String) {
        switch string {
        case "Manga":
            self = .manga
        case "Novel":
            self = .novel
        case "One Shot":
            self = .oneShot
        case "Doujin":
            self = .doujin
        case "Manhwa":
            self = .manhwa
        case "Manhua":
            self = .manhua
        case "OEL":
            self = .oel
        default:
            self = .unknown
        }
    }
}

class Manga: Entity {
    struct Author: Codable {
        var role: String
        var names: [String]
    }
    
    var chapters: Int = 0
    var volumes: Int = 0
    
    var serialization: String?
    var authors: [Author] = []
    
    var mangaStatus: MangaStatus! {
        return status as? MangaStatus
    }
    
    var mangaType: MangaType! {
        return type as? MangaType
    }

    override var malURL: String {
        return "https://myanimelist.net/manga/\(identifier)"
    }
    
    convenience init(related: RelatedEntity) {
        self.init(json: JSON(NSNull()))
        identifier = related.mangaIdentifier ?? 0
        name = related.name
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        identifier = json["id"].int ?? json["manga_id"].intValue
        
        status = MangaStatus(string: json["status"].stringValue)
        type = MangaType(string: json["type"].stringValue)
        chapters = json["chapters"].intValue
        volumes = json["volumes"].intValue
        
        serialization = json["serialization"].string
        authors = json["authors"].dictionaryValue.map { item in Author(role: item.key.replacingOccurrences(of: "&amp;", with: "&"), names: item.value.arrayValue.map({ $0["name"].stringValue })) }
    }
    
    var authorsDisplayString: String? {
        return authors.reduce(nil) { (prev, next) in (prev != nil ? prev! + "\n" : "") + "\(next.names.joined(separator: ", ")) (\(next.role))" }
    }
    
    private enum CodingKeys: String, CodingKey {
        case chapters
        case volumes
        case serialization
        case authors
        
        case status
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        chapters = try container.decode(Int.self, forKey: .chapters)
        volumes = try container.decode(Int.self, forKey: .volumes)
        serialization = try container.decode(String?.self, forKey: .serialization)
        authors = try container.decode([Author].self, forKey: .authors)
        
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
        
        status = try container.decode(MangaStatus.self, forKey: .status)
        type = try container.decode(MangaType.self, forKey: .type)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(chapters, forKey: .chapters)
        try container.encode(volumes, forKey: .volumes)
        try container.encode(serialization, forKey: .serialization)
        try container.encode(authors, forKey: .authors)
        
        try container.encode(mangaStatus!, forKey: .status)
        try container.encode(mangaType!, forKey: .type)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

extension Manga {
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
        "Seinen",
        "Josei",
        "Doujinshi",
        "Gender Bender",
        "Thriller"
    ]
}
