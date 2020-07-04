//
//  People.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 27/05/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class People {
    var identifier: Int = 0
    var name: String = ""
    var japaneseName: String = ""
    var imageURL: String = ""
    
    var otherNames: [String] = []
    var birthday: Date? = nil
    var favouriteCount: Int = 0
    
    var linkURL: String = ""
    var details: String = ""
    
    var voiceActingRoles: [VoiceActingRole] = []
    var animeStaffPositions: [AnimeStaffPosition] = []
    var publishedManga: [MangaStaffPosition] = []
    
    init(json: JSON) {
        identifier = json["id"].intValue
        name = json["name"].stringValue
        imageURL = json["image_url"].stringValue
        otherNames = json["alternate_names"].arrayValue.map { $0.stringValue }
        birthday = json["birthday"].shortDate
        japaneseName = json["family_name"].stringValue + json["given_name"].stringValue
        favouriteCount = json["favorited_count"].intValue
        linkURL = json["website_url"].stringValue
        details = json["more_details"].stringValue
        
        voiceActingRoles = json["voice_acting_roles"].arrayValue.map { VoiceActingRole(json: $0) }
        animeStaffPositions = json["anime_staff_positions"].arrayValue.map { AnimeStaffPosition(json: $0) }
        publishedManga = json["published_manga"].arrayValue.map { MangaStaffPosition(json: $0) }
    }
}

extension People {
    class VoiceActingRole {
        var characterIdentifier: Int = 0
        var characterName: String = ""
        var characterImageURL: String = ""
        var isMain: Bool = false
        var anime: Anime
        
        init(json: JSON) {
            characterIdentifier = json["id"].intValue
            characterName = json["name"].stringValue
            characterImageURL = json["image_url"].stringValue
            isMain = json["main_role"].boolValue
            anime = Anime(json: json["anime"])
        }
    }
    
    class StaffPosition {
        var position: String = ""
        var entity: Entity
        
        fileprivate init(position: String, entity: Entity) {
            self.position = position
            self.entity = entity
        }
    }
    
    class AnimeStaffPosition: StaffPosition {
        var anime: Anime {
            return entity as! Anime
        }
        
        init(json: JSON) {
            super.init(position: json["position"].stringValue, entity: Anime(json: json["anime"]))
        }
    }
    
    class MangaStaffPosition: StaffPosition {
        var manga: Manga {
            return entity as! Manga
        }
        
        init(json: JSON) {
            super.init(position: json["position"].stringValue, entity: Manga(json: json["manga"]))
        }
    }
}
