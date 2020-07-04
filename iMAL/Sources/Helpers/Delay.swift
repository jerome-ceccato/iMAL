//
//  Delay.swift
//  iMAL
//
//  Created by Jerome Ceccato on 08/07/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

func delay(_ delay: TimeInterval, closure: @escaping (() -> Void)) {
    let timeDelay = DispatchTime.now() + Double(Int64(delay * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: timeDelay, execute: closure)
}
