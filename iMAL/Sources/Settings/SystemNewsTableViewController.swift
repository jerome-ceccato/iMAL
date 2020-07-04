//
//  SystemNewsTableViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 06/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class SystemNewsTableViewController: SettingsBaseTableViewController {
    private var messages: [CommunicationMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        messages = Communication.messages
        navigationItem.title = "\(messages.count) News"
        tableView.reloadData()
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.backgroundColor = theme.global.viewBackground.color
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SystemNewsTableViewCell", for: indexPath) as! SystemNewsTableViewCell
        
        cell.fill(with: messages[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SystemNewsDetailsViewController") as? SystemNewsDetailsViewController {
            
            controller.message = messages[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.3) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
