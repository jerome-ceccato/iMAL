//
//  Cast.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class Cast {
    var identifier: Int = 0
    var name: String = ""
    var imageURL: String = ""
    var role: String? = nil
    var rank: String? = nil
    
    var voiceActors: [VoiceActor] = []
    
    init(json: JSON) {
        identifier = json["id"].intValue
        name = json["name"].stringValue
        imageURL = json["image"].stringValue
        role = json["role"].string
        rank = json["rank"].string
        
        voiceActors = json["actors"].arrayValue.map { VoiceActor(json: $0) }
    }
    
    var characterURL: URL? {
        return URL(string: "https://myanimelist.net/character/\(identifier)")
    }
}

extension Cast {
    class VoiceActor {
        var identifier: Int = 0
        var name: String = ""
        var imageURL: String = ""
        var language: String = ""
        
        init(json: JSON) {
            identifier = json["id"].intValue
            name = json["name"].stringValue
            imageURL = json["image"].stringValue
            language = json["language"].stringValue
        }

    }
}
