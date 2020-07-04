//
//  AboutTableViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AboutTableViewController: SettingsBaseTableViewController {
    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        
        versionLabel.text = BetaUtils.fullAppVersion()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actions: [IndexPath: () -> Void] = [
            IndexPath(row: 0, section: 1): { self.openURL("https://icons8.com/") },
            IndexPath(row: 1, section: 1): { self.openURL("https://bitbucket.org/ratan12/atarashii-api") },
            IndexPath(row: 2, section: 1): { self.openURL("http://anilist.co/") },
            IndexPath(row: 0, section: 2): { self.openURL("https://myanimelist.net/") },
        ]
        
        DispatchQueue.main.async {
            actions[indexPath]?()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Actions
private extension AboutTableViewController {
    func openURL(_ url: String) {
        URL(string: url)?.open(in: self)
    }
}
