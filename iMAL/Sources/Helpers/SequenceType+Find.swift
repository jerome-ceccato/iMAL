//
//  SequenceType+Find.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

extension Sequence {
    func find(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
}
