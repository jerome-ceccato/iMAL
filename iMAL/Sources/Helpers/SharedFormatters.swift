//
//  SharedFormatters.swift
//  iMAL
//
//  Created by Jerome Ceccato on 15/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class SharedFormatters {
    static let jsonDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en-US")
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return fmt
    }()
    
    static let jsonUTCDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en-US")
        fmt.timeZone = TimeZone(abbreviation: "UTC")
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt
    }()
    
    static let jsonShortDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en-US")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
    
    static let xmlOfficialAPIShortDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en-US")
        fmt.dateFormat = "MMddyyyy"
        return fmt
    }()
    
    static let jsonShortDateDisplayFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .none
        return fmt
    }()

    // MARK: -
    
    static let mediumDateDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let shortTimeDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let relativeTimeDisplayFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour]
        formatter.zeroFormattingBehavior = .dropAll
        
        var cal = Calendar.current
        cal.locale = Locale(identifier: "en-US")
        formatter.calendar = cal
        return formatter
    }()
    
    static let shortDateAndTimeDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let englishWeekdayDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    static let todayDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        formatter.formattingContext = .middleOfSentence
        formatter.locale = Locale(identifier: "en-US")
        return formatter
    }()
    
    // MARK: -
    
    static let intStringFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter
    }()
}
