//
//  DropdownManagedViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class DropdownManagedViewController: DropdownBaseViewController {
    @IBOutlet var managedTableView: ManagedTableView!

    private var data: [String] = []
    private var selectedIndex: Int?
    private var completion: ((Int?) -> Void)?
    
    @discardableResult
    class func presentController(from parent: UIViewController, data: [String], selectedIndex: Int?, completion: ((Int?) -> Void)?) -> UIViewController? {
        if let navController = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "DropdownManagedViewControllerNavigation") as? DropdownNavigationController {
            if let controller = navController.viewControllers.first as? DropdownManagedViewController {
                controller.data = data
                controller.selectedIndex = selectedIndex
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
        
        managedTableView.setup(withSimpleData: data, rowHeight: 48, selectAction: { [weak self] raw in
            if let selected = raw as? String, let index = self?.data.index(of: selected) {
                self?.completion?(index)
            }
            self?.dismiss(animated: true, completion: nil)
        })
        
        applyTheme { [unowned self] theme in
            self.managedTableView.backgroundColor = theme.dropdownPopup.background.color
            self.managedTableView.reloadData()
        }
        
        if let index = selectedIndex {
            managedTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    @IBAction override func closePressed() {
        completion?(nil)
        (navigationController ?? self).dismiss(animated: true, completion: nil)
    }
}
