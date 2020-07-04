//
//  UserEntity.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

enum EntityUserStatus: Int, Codable {
    case unknown
    case watching = 1
    case completed = 2
    case onHold = 3
    case dropped = 4
    case planToWatch = 6
}

extension Int {
    private static let scores: [String] = [
        "",
        "(1) Appalling",
        "(2) Horrible",
        "(3) Very Bad",
        "(4) Bad",
        "(5) Average",
        "(6) Fine",
        "(7) Good",
        "(8) Very Good",
        "(9) Great",
        "(10) Masterpiece"
    ]
    
    static func scoresDisplayStrings() -> [String] {
        return scores
    }
    
    var scoreDisplayString: String {
        return Int.scores[safe: self] ?? ""
    }
}

class UserEntity: Codable {
    var series: Entity! = nil
    var status: EntityUserStatus = .unknown
    var score: Int = 0
    
    var tags: [String] = []
    var comments: String?
    var startDate: Date?
    var endDate: Date?
    
    var lastUpdated: Date
    
    var statusDisplayString: String {
        return ""
    }
    
    var sortingStatus: EntityUserStatus {
        return status
    }
    
    var sortingStatusDisplayString: String {
        return ""
    }
    
    var specialStatus: String? {
        return nil
    }
    
    var restarting: Bool = false
    var restartCount: Int? = nil

    init(json: JSON) {
        score = json["score"].intValue
        
        tags = json["personal_tags"].arrayValue.map { $0.stringValue }
        comments = json["personal_comments"].string
        
        lastUpdated = json["last_updated"].date ?? Date(timeIntervalSince1970: 0)
    }
    
    private enum CodingKeys: String, CodingKey {
        case status
        case score
        case tags
        case comments
        case startDate
        case endDate
        case lastUpdated
        case restarting
    }
}
