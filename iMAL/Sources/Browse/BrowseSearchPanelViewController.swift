//
//  BrowseSearchPanelViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 30/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseSearchPanelViewController: RootViewController {
    var tableViewController: BrowseSearchPanelTableViewController!
    
    var entityKind: EntityKind!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        title = "Select filters"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Home-Browse").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.searchPressed))
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.settings.backgroundColor.color
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? BrowseSearchPanelTableViewController {
            tableViewController = controller
            controller.panelController = self
        }
    }
    
    @objc func searchPressed() {
        search(with: tableViewController.currentFilters)
    }
    
    func search(with filters: BrowseFilters) {
        view.endEditing(true)
        if let controller = UIStoryboard(name: "BrowseContent", bundle: nil).instantiateViewController(withIdentifier: "BrowseSearchContentViewController") as? BrowseSearchContentViewController {
            controller.entityKind = entityKind
            controller.currentFilters = filters
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
