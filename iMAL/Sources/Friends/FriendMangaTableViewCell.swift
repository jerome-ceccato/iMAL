//
//  FriendMangaTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendMangaTableViewCell: MangaTableViewCell {
    @IBOutlet var myInfosView: UIView!
    @IBOutlet var myInfosHiddenConstraint: NSLayoutConstraint!
    
    @IBOutlet var myInfosStatus: UILabel!
    @IBOutlet var myInfosScore: UILabel!
    @IBOutlet var myInfosScoreIcon: UIImageView!
    
    func fill(with infos: UserManga?) {
        if let infos = infos {
            myInfosHiddenConstraint.priority = UILayoutPriority.defaultLow
            myInfosStatus.text = infos.specialStatus ?? infos.statusDisplayString
            myInfosScore.text = infos.score > 0 ? "\(infos.score)" : nil
            myInfosScoreIcon.isHidden = !(infos.score > 0)
            
            [myInfosScore, myInfosStatus].forEach { $0.textColor = infos.status.colorCode() }
            myInfosScoreIcon.tintColor = infos.status.colorCode()
        }
        else {
            myInfosHiddenConstraint.priority = UILayoutPriority.required - 1
        }
    }
}
