//
//  Int+Format.swift
//  iMAL
//
//  Created by Jerome Ceccato on 24/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

extension Int {
    var formattedString: String {
        return SharedFormatters.intStringFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
