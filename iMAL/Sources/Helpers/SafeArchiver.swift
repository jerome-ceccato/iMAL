//
//  SafeArchiver.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 22/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit
import SwiftTryCatch

class SafeArchiver {
    class func unarchiveObject(withFile filename: String) -> Any? {
        var data : Any? = nil
        
        if FileManager.default.fileExists(atPath: filename) {
            SwiftTryCatch.try({
                data = NSKeyedUnarchiver.unarchiveObject(withFile: filename)
            }, catch: { ex in
                print("Failed to unarchive \(filename): \(String(describing: ex))")
            }, finallyBlock: {})
        }
        return data
    }
    
    @discardableResult
    class func archiveRootObject(_ data: Any, toFile filename: String) -> Bool {
        var result: Bool = false
        
        SwiftTryCatch.try({
            result = NSKeyedArchiver.archiveRootObject(data, toFile: filename)
        }, catch: { ex in
            print("Failed to archive \(filename): \(String(describing: ex))")
        }, finallyBlock: {})
        
        return result
    }
}
