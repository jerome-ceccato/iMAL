//
//  UIScrollView+trueContentInset.swift
//  iMAL
//
//  Created by Jerome Ceccato on 08/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

extension UIScrollView {
    var trueContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        }
        else {
            return contentInset
        }
    }
    
    var optionalSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        }
        else {
            return .zero
        }
    }
}
