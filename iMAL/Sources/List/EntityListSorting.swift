//
//  EntityListSorting.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

struct EntityListSorting: Equatable {
    enum GroupingOptions: Int {
        case status = 0
        case score = 1
        case alphabetically = 2
        case tags = 3
    }

    enum SortingOptions: Int {
        case alphabetically = 0
        case lastUpdatedFirst = 1
        case score = 2
    }
    
    var grouping: GroupingOptions
    var sorting: SortingOptions
    
    init(grouping: GroupingOptions = .status, sorting: SortingOptions = .alphabetically) {
        self.grouping = grouping
        self.sorting = sorting
    }
    
    struct SectionInfos {
        var identifier: AnyObject
        var title: String
        
        init(identifier: AnyObject, title: String) {
            self.identifier = identifier
            self.title = title
        }
    }
}

func ==(lhs: EntityListSorting, rhs: EntityListSorting) -> Bool {
    return lhs.grouping == rhs.grouping && lhs.sorting == rhs.sorting
}

extension EntityListSorting {
    var displayName: String {
        return grouping.displayName
    }
    
    var wantsSoftReloadOnUpdate: Bool {
        return grouping == .tags
    }
}

extension EntityListSorting.GroupingOptions {
    var displayName: String {
        switch self {
        case .status:
            return "Status"
        case .score:
            return "Score"
        case .alphabetically:
            return "A-Z"
        case .tags:
            return "Tags"
        }
    }
}

extension EntityListSorting.SortingOptions {
    var displayName: String {
        switch self {
        case .alphabetically:
            return "A-Z"
        case .lastUpdatedFirst:
            return "Last updated first"
        case .score:
            return "Score"
        }
    }
}
