//
//  AnimeList.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class AnimeList: IndexableList, Codable {
    var items: [UserAnime] = []
    var _searchIndex: [Int: UserAnime]? = nil
    
    var daysWatched: Double = 0
    
    convenience init(json: JSON) {
        self.init()
        
        daysWatched = json["statistics"]["days"].doubleValue
        items = json["anime"].arrayValue.map { UserAnime(json: $0) }
    }
    
    private enum CodingKeys: String, CodingKey {
        case items
        case daysWatched
    }
}
