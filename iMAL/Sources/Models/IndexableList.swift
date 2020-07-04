//
//  IndexableList.swift
//  iMAL
//
//  Created by Jerome Ceccato on 13/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

protocol IndexableList: class {
    associatedtype T: UserEntity

    var items: [T] { get set }
    var _searchIndex: [Int: T]? { get set }
}

extension IndexableList {
    private var searchIndex: [Int: T] {
        if let index = _searchIndex {
            return index
        }
        _searchIndex = buildSearchIndex()
        return _searchIndex!
    }
    
    private func buildSearchIndex() -> [Int: T] {
        var index = [Int: T]()
        items.forEach { item in
            index[item.series.identifier] = item
        }
        return index
    }
    
    func updateSearchIndex(with item: T, delete: Bool = false) {
        if _searchIndex != nil {
            if delete {
                _searchIndex!.removeValue(forKey: item.series.identifier)
            }
            else {
                _searchIndex![item.series.identifier] = item
            }
        }
    }
    
    func invalidateSearchIndex() {
        _searchIndex = nil
    }
    
    func find(by identifier: Int) -> T? {
        return searchIndex[identifier]
    }
}
