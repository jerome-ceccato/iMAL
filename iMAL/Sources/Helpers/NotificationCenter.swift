//
//  NotificationCenter.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

private class Observer {
    weak var observer: AnyObject?
    var notifications: [String:NSObjectProtocol] = [:]
    
    init(observer: AnyObject?) {
        self.observer = observer
    }
}

open class NotificationCenter {
    private static var observers = [Observer]()
    
    public static func register(_ object: AnyObject, _ name: String, block:@escaping (Notification) -> Void) {
        for observer in observers {
            if observer.observer === object {
                NotificationCenter.observer(observer, addNotificationWithName: name, block: block)
                return
            }
        }

        let observer = Observer(observer: object)
        NotificationCenter.observer(observer, addNotificationWithName: name, block: block)
        observers.append(observer)
    }
    
    public static func unregister(_ object: AnyObject, _ name: String? = nil) {
        if let name = name {
            for observer in observers {
                if observer.observer === object {
                    if let item = observer.notifications[name] {
                        Foundation.NotificationCenter.default.removeObserver(item)
                        observer.notifications.removeValue(forKey: name)
                    }
                    return
                }
            }
        }
        else {
            for (i, item) in observers.enumerated().reversed() {
                if item.observer === object {
                    item.notifications.values.forEach(Foundation.NotificationCenter.default.removeObserver)
                    observers.remove(at: i)
                }
            }
        }
    }
    
    private static func observer(_ observer: Observer, addNotificationWithName name: String, block:@escaping (Notification) -> Void) {
        observer.notifications[name] = Foundation.NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: OperationQueue.main, using: block)
    }
}
