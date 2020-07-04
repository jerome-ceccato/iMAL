//
//  MangaList.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class MangaList: IndexableList, Codable {
    var items: [UserManga] = []
    var _searchIndex: [Int: UserManga]? = nil

    convenience init(json: JSON) {
        self.init()
        
        items = json["manga"].arrayValue.map { UserManga(json: $0) }
    }
    
    private enum CodingKeys: String, CodingKey {
        case items
    }
}
