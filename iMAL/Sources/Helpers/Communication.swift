//
//  Communication.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 05/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import SwiftyJSON

class Communication {
    private static let instance = Communication()
    
    var messages: [CommunicationMessage] = []
    var lastUpdate: Date? = nil
}

@objc(CommunicationMessage)
class CommunicationMessage: NSObject, NSCoding {
    var id: Int
    var title: String
    var message: String
    var date: Date
    var important: Bool
    var viewed: Bool = false
    
    init(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        message = json["message"].stringValue
        date = json["date"].UTCDate ?? Date()
        important = json["important"].boolValue
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(message, forKey: "message")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(important, forKey: "important")
        aCoder.encode(viewed, forKey: "viewed")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeInteger(forKey: "id")
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        message = aDecoder.decodeObject(forKey: "message") as? String ?? ""
        date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        important = aDecoder.decodeBool(forKey: "important")
        viewed = aDecoder.decodeBool(forKey: "viewed")
    }
}


// MARK: - Storage
extension Communication {
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let messagesArchiveURL = documentsDirectory.appendingPathComponent("imal_messages_3.4")
    
    class func loadMessages() -> [CommunicationMessage] {
        return SafeArchiver.unarchiveObject(withFile: messagesArchiveURL.path) as? [CommunicationMessage] ?? []
    }
    
    class func saveMessages(_ messages: [CommunicationMessage]) {
        SafeArchiver.archiveRootObject(messages, toFile: messagesArchiveURL.path)
    }
}

// MARK: - Fetching messages
extension Communication {
    static let lastFetchedIDKey = "imal-communication-last-id_3.4"
    static var lastFetchedID: Int {
        get {
            return UserDefaults.standard.integer(forKey: lastFetchedIDKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastFetchedIDKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    class func fetchNewMessages(_ completion: @escaping ([CommunicationMessage]) -> Void) {
        API.systemMessages(lastID: lastFetchedID).request { (success, messages: [CommunicationMessage]?) in
            if let messages = messages, success {
                completion(messages)
            }
            else {
                completion([])
            }
        }
    }
}

// MARKL - Updating
extension Communication {
    class func updateIfNeeded() {
        if let lastUpdate = instance.lastUpdate {
            if lastUpdate.addingTimeInterval(3600) < Date() {
                fetchNewMessagesAndUpdate()
            }
        }
        else {
            instance.messages = loadMessages()
            fetchNewMessagesAndUpdate()
        }
    }
    
    private class func fetchNewMessagesAndUpdate() {
        fetchNewMessages { newMessages in
            let firstTime = lastFetchedID == 0
            
            instance.messages.append(contentsOf: newMessages.filter({ new in instance.messages.find({ old in old.id == new.id }) == nil}))
            if firstTime {
                instance.messages.forEach { if !$0.important { $0.viewed = true } }
            }
            if !newMessages.isEmpty {
                instance.messages.sort(by: { a, b in a.date > b.date })
                saveMessages(instance.messages)
            }
            lastFetchedID = instance.messages.reduce(0, { max($0, $1.id) })
            updateWithMessages(instance.messages)
        }
        instance.lastUpdate = Date()
    }
    
    static var unreadMessages: Int {
        return instance.messages.reduce(0) { (n, message) in
            return n + (message.viewed ? 0 : 1)
        }
    }
    
    static var messages: [CommunicationMessage] {
        return instance.messages
    }
    
    class func markMessageAsRead(_ message: CommunicationMessage) {
        message.viewed = true
        saveMessages(instance.messages)
        updateWithMessages(instance.messages)
    }
    
    private static let messagesUpdatedNotification = "imal-messages"
    class func updateWithMessages(_ messages: [CommunicationMessage]) {
        Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: messagesUpdatedNotification), object: nil)
    }
    
    class func handleMessagesUpdateNotification(_ object: AnyObject, update: @escaping () -> Void) {
        NotificationCenter.register(object, messagesUpdatedNotification, block: { notif in
            update()
        })
    }
}
