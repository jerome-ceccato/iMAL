//
//  Episode.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 29/01/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class Episode {
    var number: Int = 0
    var title: String = ""
    var englishTitle: String? = nil
    var japaneseTitle: String? = nil
    var airedDate: Date? = nil
    
    init(json: JSON) {
        number = json["number"].intValue
        title = json["title"].stringValue
        englishTitle = json["other_titles"]["english"].arrayValue.first?.string
        japaneseTitle = json["other_titles"]["japanese"].arrayValue.first?.string
        airedDate = json["air_date"].shortDate
    }
    
    var alternativeTitlesDisplayString: String? {
        if let en = englishTitle {
            if let ja = japaneseTitle {
                return "\(en) (\(ja))"
            }
            return en
        }
        return japaneseTitle
    }
}
