//
//  CollectionType+SafeSubscript.swift
//  iMAL
//
//  Created by Jerome Ceccato on 10/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
