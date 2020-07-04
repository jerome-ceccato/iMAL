//
//  SafeArchiver.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 22/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class SafeArchiver {
    class func unarchiveObject(withFile filename: String) -> Any? {
        var data : Any? = nil
        
        if FileManager.default.fileExists(atPath: filename) {
            do {
                let rawData = try Data(contentsOf: URL(fileURLWithPath: filename))
                data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawData)
            } catch {
                return nil
            }
        }
        return data
    }
    
    @discardableResult
    class func archiveRootObject(_ data: Any, toFile filename: String) -> Bool {
        do {
            if #available(iOS 11.0, *) {
                let archive = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
                try archive.write(to: URL(fileURLWithPath: filename))
                return true
            } else {
                return NSKeyedArchiver.archiveRootObject(data, toFile: filename)
            }
        } catch  {
            return false
        }
    }
}
