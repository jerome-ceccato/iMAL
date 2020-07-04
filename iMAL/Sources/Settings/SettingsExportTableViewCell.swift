//
//  SettingsExportTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class SettingsExportTableViewCell: SettingsTableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var animeCacheLabel: UILabel!
    @IBOutlet var mangaCacheLabel: UILabel!
    
    func fill(with userData: UserDataCache.UserData) {
        usernameLabel.text = userData.username

        if let animelist = userData.animeList {
            self.animeCacheLabel.text = "\(animelist.items.count) anime"
        }
        else {
            self.animeCacheLabel.text = "not loaded"
        }
        
        if let mangalist = userData.mangaList {
            self.mangaCacheLabel.text = "\(mangalist.items.count) manga"
        }
        else {
            self.mangaCacheLabel.text = "not loaded"
        }
    }
}
