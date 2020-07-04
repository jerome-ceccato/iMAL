//
//  BrowseData.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 10/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class BrowseData {
    class Section {
        enum Kind {
            case schedule
            case top
            case popular
            case upcoming
            case justAdded
        }
        
        var schedule: [Entity]
        var top: [Entity]
        var popular: [Entity]
        var upcoming: [Entity]
        var justAdded: [Entity]
        
        init(json: JSON, new: (JSON) -> Entity) {
            schedule = json["schedule"].arrayValue.map { new($0) }
            top = json["top"].arrayValue.map { new($0) }
            popular = json["popular"].arrayValue.map { new($0) }
            upcoming = json["upcoming"].arrayValue.map { new($0) }
            justAdded = json["justAdded"].arrayValue.map { new($0) }
        }
        
        func compiled() -> [(entities: [Entity], kind: BrowseData.Section.Kind)] {
            return [(self.schedule, .schedule), (self.top, .top), (self.popular, .popular), (self.upcoming, .upcoming), (self.justAdded, .justAdded)].filter { !$0.0.isEmpty }
        }
    }
    
    var anime: Section
    var manga: Section
    
    init(json: JSON) {
        anime = Section(json: json["anime"], new: Anime.init)
        manga = Section(json: json["manga"], new: Manga.init)
    }
}
