//
//  Review.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/01/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class Review {
    var rating: Int = 0
    var username: String = ""
    var avatarURL: String? = nil
    var helpfulCount: Int = 0
    var date: Date? = nil
    
    var mainMetric: Int = 0
    var mainMetricTotal: Int = 0
    var mainMetricDisplayString: String? { return nil }
    
    var review: String = ""
    var reviewPlainText: String = ""
    
    init(json: JSON) {
        rating = json["rating"].intValue
        username = json["username"].stringValue
        avatarURL = json["avatar_url"].string
        helpfulCount = json["helpful"].int ?? json["helpful_total"].intValue
        date = json["date"].shortDate
        
        review = json["review"].stringValue
        reviewPlainText = review.plainTextFromHTML() ?? ""
    }
}
