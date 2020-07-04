//
//  BrowseFilters.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 30/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BrowseFilters {
    var sortOrder: SortOrder = .score
    var genres: [String] = []
    var period: (start: Date?, end: Date?) = (nil, nil)
    var rating: EntityRating?
    var status: EntityStatus?
    var type: EntityType?
    var score: Int?
    var searchTerms: String = ""
    
    enum SortOrder: String {
        case title = "Title"
        case score = "Score"
        case members = "Popularity"
        case newest = "Newest"
        case oldest = "Oldest"
    }
}

extension BrowseFilters.SortOrder {
    var identifier: String {
        switch self {
        case .title:
            return "title"
        case .score:
            return "score"
        case .members:
            return "members"
        case .newest:
            return "start date"
        case .oldest:
            return "start date"
        }
    }
    
    private var reversed: Bool {
        switch self {
        case .title: // A -> Z
            return false
        case .score: // 10 -> 0
            return true
        case .members: // 1000 -> 10
            return true
        case .newest: // Today -> Yesterday
            return true
        case .oldest: // Yesterday -> Today
            return false
        }
    }
    
    var order: Int {
        return reversed ? 1 : 0
    }
}

extension BrowseFilters {
    func toParameters() -> [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        
        parameters["sort"] = sortOrder.identifier as AnyObject
        parameters["reverse"] = sortOrder.order as AnyObject
        
        if !genres.isEmpty {
            parameters["genres"] = genres.joined(separator: ",") as AnyObject
        }
        
        if let startDate = period.start {
            parameters["start_date"] = startDate.shortDateAPIString as AnyObject
        }
        if let endDate = period.end {
            parameters["end_date"] = endDate.shortDateAPIString as AnyObject
        }
        
        if let rating = rating {
            parameters["rating"] = rating.rawValue as AnyObject
        }
        
        if let status = status {
            parameters["status"] = status.rawValue as AnyObject
        }
        
        if let type = type {
            parameters["type"] = type.rawValue as AnyObject
        }
        
        if let score = score {
            parameters["score"] = score as AnyObject
        }
        
        if !searchTerms.isEmpty {
            parameters["keyword"] = searchTerms as AnyObject
        }
        
        return parameters
    }
}
