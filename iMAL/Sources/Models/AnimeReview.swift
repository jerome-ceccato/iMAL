//
//  AnimeReview.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/01/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class AnimeReview: Review {
    override init(json: JSON) {
        super.init(json: json)
        
        mainMetric = json["watched_episodes"].intValue
        mainMetricTotal = json["episodes"].intValue
    }
    
    override var mainMetricDisplayString: String? {
        if mainMetric > 0 {
            if mainMetricTotal > 0 {
                return "\(mainMetric) / \(mainMetricTotal) episode\(mainMetric > 1 ? "s" : "") watched"
            }
            return "\(mainMetric) episode\(mainMetric > 1 ? "s" : "") watched"
        }
        return nil
    }
}
