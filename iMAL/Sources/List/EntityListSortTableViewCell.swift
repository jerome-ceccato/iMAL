//
//  EntityListSortTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/11/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityListSortTableViewCell: DropdownManagedTableViewCell {
    override func fill(with data: Any, context: ManagedTableView.Context) {
        if let data = data as? EntityListSorting.GroupingOptions {
            titleLabel.text = data.displayName
        }
        else if let data = data as? EntityListSorting.SortingOptions {
            titleLabel.text = data.displayName
        }
    }
}
