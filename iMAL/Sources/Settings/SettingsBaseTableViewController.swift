//
//  SettingsBaseTableViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 07/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class SettingsBaseTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.settings.backgroundColor.color
            self.tableView.backgroundColor = theme.settings.backgroundColor.color
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
        }
    }
}
