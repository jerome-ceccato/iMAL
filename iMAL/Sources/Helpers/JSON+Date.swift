//
//  JSON+Date.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import SwiftyJSON

extension JSON {
    public var date: Date? {
        get {
            return self.string?.asDate
        }
    }
    
    public var UTCDate: Date? {
        get {
            return self.string?.asUTCDate
        }
    }

    public var shortDate: Date? {
        get {
            return self.string?.asShortDate
        }
    }
}
