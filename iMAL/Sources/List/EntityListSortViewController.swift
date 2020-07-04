//
//  EntityListSortViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/11/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityListSortViewController: DropdownBaseViewController {
    @IBOutlet var optionsTableView: ManagedTableView!
    
    private var initialOption = EntityListSorting()
    private var currentOption = EntityListSorting()
    private weak var parentController: EntityListViewController?
    
    private var completion: (() -> Void)?
    
    @discardableResult
    class func presentControllerFromController(_ parent: EntityListViewController, selectedOption: EntityListSorting, completion: (() -> Void)?) -> UIViewController? {
        if let navController = UIStoryboard(name: "EntityListSort", bundle: nil).instantiateInitialViewController() as? DropdownNavigationController {
            if let controller = navController.viewControllers.first as? EntityListSortViewController {
                controller.initialOption = selectedOption
                controller.currentOption = selectedOption
                controller.parentController = parent
                controller.completion = completion
                
                controller.setupModalTransitioning()
                parent.present(navController, animated: true, completion: nil)
                return navController
            }
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data: TableViewData = [
            (section: "Group list by...", items: [
                EntityListSorting.GroupingOptions.status,
                EntityListSorting.GroupingOptions.score,
                EntityListSorting.GroupingOptions.alphabetically,
                EntityListSorting.GroupingOptions.tags
                ]),
            (section: "Sort list by...", items: [
                EntityListSorting.SortingOptions.alphabetically,
                EntityListSorting.SortingOptions.lastUpdatedFirst,
                EntityListSorting.SortingOptions.score
                ])]
        
        optionsTableView.headerNibName = "EntityListSortHeader"
        optionsTableView.headerHeight = 64
        optionsTableView.additionalSpacing = 0
        optionsTableView.allowsMultipleSelection = true
        optionsTableView.manageScrollAutomatically = true
        optionsTableView.setup(withData: data, heightForItem: { _ in 48 }, selectAction: { [weak self] raw in
            if let grouping = raw as? EntityListSorting.GroupingOptions {
                self?.currentOption.grouping = grouping
            }
            else if let sorting = raw as? EntityListSorting.SortingOptions {
                self?.currentOption.sorting = sorting
            }
        })
        
        applyTheme { [unowned self] theme in
            self.optionsTableView.backgroundColor = theme.dropdownPopup.background.color
            self.optionsTableView.reloadData()
        }
        
        optionsTableView.selectRow(at: IndexPath(row: currentOption.grouping.rawValue, section: 0), animated: false, scrollPosition: .none)
        optionsTableView.selectRow(at: IndexPath(row: currentOption.sorting.rawValue, section: 1), animated: false, scrollPosition: .none)
    }
    
    @IBAction override func closePressed() {
        dismissWithResult(currentOption)
    }
    
    func dismissWithResult(_ option: EntityListSorting) {
        if option != initialOption {
            parentController?.reload(withNewSortingOption: option)
        }
        completion?()
        (navigationController ?? self).dismiss(animated: true, completion: nil)
    }
}
