//
//  Array+add.swift
//  iMAL
//
//  Created by Jerome Ceccato on 23/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

public func +<Element>(lhs: [Element], rhs: Element) -> [Element] {
    var new = [Element]()
    new.append(contentsOf: lhs)
    new.append(rhs)
    return new
}
