//
//  String+Bool.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 18/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
