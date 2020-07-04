//
//  Date+Format.swift
//  iMAL
//
//  Created by Jerome Ceccato on 23/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

extension Date {
    var shortDateDisplayString: String {
        return SharedFormatters.jsonShortDateDisplayFormatter.string(from: self)
    }
    
    var shortDateAPIString: String {
        return SharedFormatters.jsonShortDateFormatter.string(from: self)
    }
    
    var shortDateOfficialXMLAPIString: String {
        return SharedFormatters.xmlOfficialAPIShortDateFormatter.string(from: self)
    }
}

extension String {
    public var asDate: Date? {
        get {
            return SharedFormatters.jsonDateFormatter.date(from: self)
        }
    }
    
    public var asUTCDate: Date? {
        get {
            return SharedFormatters.jsonUTCDateFormatter.date(from: self)
        }
    }
    
    public var asShortDate: Date? {
        get {
            return SharedFormatters.jsonShortDateFormatter.date(from: self)
        }
    }
    
    public var asShortDateDisplayString: Date? {
        get {
            return SharedFormatters.jsonShortDateDisplayFormatter.date(from: self)
        }
    }
}
