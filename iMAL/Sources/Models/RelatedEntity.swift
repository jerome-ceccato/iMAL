//
//  RelatedEntity.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class RelatedEntity: Codable {
    var animeIdentifier: Int? = nil
    var mangaIdentifier: Int? = nil
    
    var name: String = ""
    
    convenience init(json: JSON) {
        self.init()

        animeIdentifier = json["anime_id"].int
        mangaIdentifier = json["manga_id"].int
        name = json["title"].stringValue
    }
}
