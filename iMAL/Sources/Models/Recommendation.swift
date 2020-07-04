//
//  Recommendation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/02/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class Recommendation {
    var entity: TypedEntity
    var recommendations: [(user: String, content: String)] = []
    
    init(json: JSON, kind: EntityKind) {
        entity = TypedEntity(json: json["item"], kind: kind)
        recommendations = json["recommendations"].arrayValue.map { (user: $0["username"].stringValue, content: $0["information"].stringValue) }
    }
}
