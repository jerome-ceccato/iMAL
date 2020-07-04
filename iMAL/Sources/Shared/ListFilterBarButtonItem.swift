//
//  ListFilterBarButtonItem.swift
//  iMAL
//
//  Created by Jerome Ceccato on 12/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

enum ListFilter: Int {
    case none = 0
    case partial = 1
    case full = 2
}

class ListFilterBarButtonItem: UIBarButtonItem {
    private weak var ownerController: UIViewController!
    private var completion: ((ListFilter) -> Void)!
    private(set) var currentFilter: ListFilter = .none
    
    var displayStrings: [String] = ["None", "Partial", "Full"]
    
    convenience init(owner: UIViewController, filterChanged: @escaping (ListFilter) -> Void) {
        self.init(image: #imageLiteral(resourceName: "Filter-off").withRenderingMode(.alwaysTemplate), style: .plain, target: nil, action: nil)
        target = self
        action = #selector(self.toggle)
        
        ownerController = owner
        completion = filterChanged
    }
    
    @objc func toggle() {
        DropdownManagedViewController.presentController(from: ownerController, data: displayStrings, selectedIndex: currentFilter.rawValue) { raw in
            if let raw = raw, let filter = ListFilter(rawValue: raw) {
                self.currentFilter = filter
                self.theme()
                self.completion?(filter)
            }
        }
    }
    
    private func theme() {
        let newImage = (currentFilter != .none ? #imageLiteral(resourceName: "Filter-on") : #imageLiteral(resourceName: "Filter-off")).withRenderingMode(.alwaysTemplate)
        image = newImage
    }
}
