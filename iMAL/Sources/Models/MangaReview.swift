//
//  MangaReview.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/01/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class MangaReview: Review {
    override init(json: JSON) {
        super.init(json: json)
        
        mainMetric = json["chapters_read"].intValue
        mainMetricTotal = json["chapters"].intValue
    }
    
    override var mainMetricDisplayString: String? {
        if mainMetric > 0 {
            if mainMetricTotal > 0 {
                return "\(mainMetric) / \(mainMetricTotal) chapter\(mainMetric > 1 ? "s" : "") read"
            }
            return "\(mainMetric) chapter\(mainMetric > 1 ? "s" : "") read"
        }
        return nil
    }
}
