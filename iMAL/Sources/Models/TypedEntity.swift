//
//  TypedEntity.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/02/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

enum EntityKind {
    case anime
    case manga
}

extension EntityKind {
    var shortIdentifier: String {
        switch self {
        case .anime:
            return "a"
        case .manga:
            return "m"
        }
    }
}

class TypedEntity: NSObject {
    var kind: EntityKind
    var entity: Entity!
    
    var anime: Anime? {
        return kind == .anime ? (entity as? Anime) : nil
    }
    
    var manga: Manga? {
        return kind == .manga ? (entity as? Manga) : nil
    }
    
    init(json: JSON, kind: EntityKind) {
        self.kind = kind
        switch kind {
        case .anime:
            entity = Anime(json: json)
        case .manga:
            entity = Manga(json: json)
        }
    }
    
    init(entity: Entity, kind: EntityKind) {
        self.kind = kind
        self.entity = entity
    }
}
