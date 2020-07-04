//
//  Friend.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 11/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class Friend: NSObject, NSCoding {
    var name: String = ""
    var avatarURL: String?
    
    init(name: String, avatarURL: String?) {
        self.name = name
        self.avatarURL = avatarURL
    }
    
    init(json: JSON) {
        name = json["name"].stringValue
        avatarURL = json["profile"]["avatar_url"].string
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(avatarURL, forKey: "avatarURL")
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        avatarURL = aDecoder.decodeObject(forKey: "avatarURL") as? String
    }
}
