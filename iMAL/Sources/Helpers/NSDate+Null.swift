//
//  NSDate+Null.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 27/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

private let nullDateStorage = Date.distantPast

extension Date {
    static var nullDate: Date {
        return nullDateStorage
    }
}
