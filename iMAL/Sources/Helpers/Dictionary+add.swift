//
//  Dictionary+add.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 18/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

func + <K,V> (left: Dictionary<K,V>, right: Dictionary<K,V>?) -> Dictionary<K,V> {
    guard let right = right else { return left }
    return left.reduce(right) {
        var new = $0 as [K:V]
        new.updateValue($1.1, forKey: $1.0)
        return new
    }
}
