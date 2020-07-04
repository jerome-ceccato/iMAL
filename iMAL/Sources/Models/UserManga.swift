//
//  UserManga.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import SwiftyJSON

extension UserManga {
    class Status {
        static let specialStatus: String = "Re-reading"
        
        private static var statuses: [(String, EntityUserStatus)] = [
            ("Reading", .watching),
            ("Completed", .completed),
            ("On-Hold", .onHold),
            ("Dropped", .dropped),
            ("Plan to Read", .planToWatch),
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
            case "reading":
                return .watching
            case "completed":
                return .completed
            case "on-hold":
                return .onHold
            case "dropped":
                return .dropped
            case "plan to read":
                return .planToWatch
            default:
                return .unknown
            }
        }
    }
}

class UserManga: UserEntity {
    var readVolumes: Int = 0
    var readChapters: Int = 0
    
    var mangaSeries: Manga! {
        return series as? Manga
    }
    
    override var sortingStatus: EntityUserStatus {
        return restarting ? .watching : status
    }
    
    override var specialStatus: String? {
        return restarting ? Status.specialStatus  : nil
    }
    
    override var statusDisplayString: String {
        return Status.displayString(status)
    }
    
    override var sortingStatusDisplayString: String {
        return Status.displayString(sortingStatus)
    }
    
    init(series: Manga) {
        super.init(json: JSON(NSNull()))
        self.series = series
    }

    override init(json: JSON) {
        super.init(json: json)
        
        series = Manga(json: json)
        status = Status.new(string: json["read_status"].stringValue)
        readChapters = json["chapters_read"].intValue
        readVolumes = json["volumes_read"].intValue
        
        restarting = json["rereading"].boolValue
        
        startDate = json["reading_start"].shortDate as Date?
        endDate = json["reading_end"].shortDate as Date?
        
        restartCount = json["reread_count"].int
    }
    
    class func validateUserInfo(json: JSON) -> Bool {
        return json["read_status"].exists() || json["chapters_read"].exists() || json["volumes_read"].exists() || json["score"].exists()
    }
    
    private enum CodingKeys: String, CodingKey {
        case readVolumes
        case readChapters
        
        case series
        case restartCount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        readChapters = try container.decode(Int.self, forKey: .readChapters)
        readVolumes = try container.decode(Int.self, forKey: .readVolumes)
        
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
        
        series = try container.decode(Manga.self, forKey: .series)
        restartCount = try container.decode(Int?.self, forKey: .restartCount)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(readChapters, forKey: .readChapters)
        try container.encode(readVolumes, forKey: .readVolumes)
        
        try container.encode(mangaSeries!, forKey: .series)
        try container.encode(restartCount, forKey: .restartCount)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}
