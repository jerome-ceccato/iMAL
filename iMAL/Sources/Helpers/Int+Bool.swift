//
//  Int+Bool.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

extension Int {
    init(_ source: Bool) {
        self = source ? 1 : 0
    }
}

extension Bool {
    init(_ source: Int) {
        self = source != 0
    }
}
