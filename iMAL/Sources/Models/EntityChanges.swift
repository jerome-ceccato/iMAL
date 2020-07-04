//
//  EntityChanges.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import AEXML

class EntityChanges {
    var originalEntity: UserEntity!
    
    var statusChanges: EntityUserStatus?
    var scoreChanges: Int?
    var startDateChanges: Date?
    var endDateChanges: Date?
    var tagsChanges: [String]?
    
    var restartingChanges: Bool?
    
    var specialStatus: String? {
        return nil
    }
    
    var statusDisplayString: String {
        return ""
    }
    
    // MARK: - Accessors
    
    var status: EntityUserStatus {
        get {
            return statusChanges ?? originalEntity.status
        }
        set {
            statusChanges = newValue
        }
    }
    
    var score: Int {
        get {
            return scoreChanges ?? originalEntity.score
        }
        set {
            scoreChanges = newValue
        }
    }
    
    var startDate: Date? {
        get {
            return startDateChanges ?? originalEntity.startDate as Date?
        }
        set {
            startDateChanges = newValue
        }
    }
    
    var endDate: Date? {
        get {
            return endDateChanges ?? originalEntity.endDate as Date?
        }
        set {
            endDateChanges = newValue
        }
    }
    
    var tags: [String] {
        get {
            return tagsChanges ?? originalEntity.tags
        }
        set {
            tagsChanges = newValue
        }
    }
    
    var restarting: Bool {
        get {
            return restartingChanges ?? originalEntity.restarting
        }
        set {
            restartingChanges = newValue
        }
    }
    
    var restartCount: Int? {
        get {
            if let restart = originalEntity.restartCount {
                if status == .completed && !restarting && originalEntity.restarting {
                    return restart + 1
                }
            }
            return nil
        }
    }
    
    // MARK: - Actions

    func toUpdateParameters() -> [String: AnyObject] {
        var data = [String: AnyObject]()
        
        if let newStatus = statusChanges {
            data["status"] = newStatus.rawValue as AnyObject?
        }
        if let newScore = scoreChanges {
            data["score"] = newScore as AnyObject?
        }
        if let newStartDate = startDateChanges {
            if newStartDate == Date.nullDate {
                data["date_start"] = "00000000" as AnyObject?
            }
            else {
                data["date_start"] = newStartDate.shortDateOfficialXMLAPIString as AnyObject?
            }
        }
        if let newEndDate = endDateChanges {
            if newEndDate == Date.nullDate {
                data["date_finish"] = "00000000" as AnyObject?
            }
            else {
                data["date_finish"] = newEndDate.shortDateOfficialXMLAPIString as AnyObject?
            }
        }
        if let newTags = tagsChanges {
            data["tags"] = newTags.joined(separator: ",") as AnyObject?
        }
        
        return data
    }
    
    func asXMLString() -> String {
        let document = AEXMLDocument(root: AEXMLElement(name: "entry"), options: AEXMLOptions())
        let items = toUpdateParameters()
        for (key, value) in items {
            document.root.addChild(name: key, value: "\(value)", attributes: [:])
        }

        return document.xml
    }
    
    func commitChanges() {
        originalEntity.status = status
        originalEntity.score = score
        originalEntity.startDate = startDate == Date.nullDate ? nil : startDate
        originalEntity.endDate = endDate == Date.nullDate ? nil : endDate
        originalEntity.tags = tags
        originalEntity.restarting = restarting
        originalEntity.restartCount = restartCount
        
        originalEntity.lastUpdated = Date()
    }
    
    func revertChanges() {
        statusChanges = nil
        scoreChanges = nil
        startDateChanges = nil
        endDateChanges = nil
        tagsChanges = nil
        restartingChanges = nil
    }
    
    func hasChanges() -> Bool {
        return statusChanges != nil
            || scoreChanges != nil
            || startDateChanges != nil
            || endDateChanges != nil
            || tagsChanges != nil
            || restartingChanges != nil
    }
}
