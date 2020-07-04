//
//  UserAnime.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

extension UserAnime {
    class Status {
        static let specialStatus: String = "Rewatching"
        
        private static var statuses: [(String, EntityUserStatus)] = [
            ("Watching", .watching),
            ("Completed", .completed),
            ("On-Hold", .onHold),
            ("Dropped", .dropped),
            ("Plan to Watch", .planToWatch),
            (Status.specialStatus, .completed)
        ]
        
        class var displayStrings: [String] {
            return statuses.map { (string, _) in string }
        }
        
        class func statusForDisplayString(_ string: String) -> EntityUserStatus {
            return statuses.find { (str, _) in str == string }?.1 ?? .unknown
        }
        
        class func displayString(_ status: EntityUserStatus) -> String {
            return Status.statuses.find { (_, value) in value == status }?.0 ?? ""
        }

        class func new(string: String) -> EntityUserStatus {
            switch string {
            case "watching":
                return .watching
            case "completed":
                return .completed
            case "on-hold":
                return .onHold
            case "dropped":
                return .dropped
            case "plan to watch":
                return .planToWatch
            default:
                return .unknown
            }
        }
    }
}

class UserAnime: UserEntity {
    var watchedEpisodes: Int = 0
    
    var animeSeries: Anime! {
        return series as? Anime
    }
    
    override var statusDisplayString: String {
        return Status.displayString(status)
    }
    
    override var sortingStatusDisplayString: String {
        return Status.displayString(sortingStatus)
    }

    override var sortingStatus: EntityUserStatus {
        return restarting ? .watching : status
    }
    
    override var specialStatus: String? {
        return restarting ? Status.specialStatus : nil
    }
    
    init(series: Anime) {
        super.init(json: JSON(NSNull()))
        self.series = series
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        series = Anime(json: json)
        status = Status.new(string: json["watched_status"].stringValue)
        watchedEpisodes = json["watched_episodes"].intValue
        
        restarting = json["rewatching"].boolValue
        
        startDate = json["watching_start"].shortDate as Date?
        endDate = json["watching_end"].shortDate as Date?
        
        restartCount = json["rewatch_count"].int
    }
    
    class func validateUserInfo(json: JSON) -> Bool {
        return json["watched_status"].exists() || json["watched_episodes"].exists() || json["score"].exists()
    }
    
    private enum CodingKeys: String, CodingKey {
        case watchedEpisodes
        
        case series
        case restartCount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        watchedEpisodes = try container.decode(Int.self, forKey: .watchedEpisodes)
        
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
        
        series = try container.decode(Anime.self, forKey: .series)
        restartCount = try container.decode(Int?.self, forKey: .restartCount)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(watchedEpisodes, forKey: .watchedEpisodes)
        
        try container.encode(animeSeries!, forKey: .series)
        try container.encode(restartCount, forKey: .restartCount)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}
