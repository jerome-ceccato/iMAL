//
//  UILayoutPriority+offset.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/11/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

extension UILayoutPriority {
    func offset(by value: Float) -> UILayoutPriority {
        return UILayoutPriority(rawValue: rawValue + value)
    }
}

func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
    return lhs.offset(by: rhs)
}

func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
    return lhs.offset(by: -rhs)
}
