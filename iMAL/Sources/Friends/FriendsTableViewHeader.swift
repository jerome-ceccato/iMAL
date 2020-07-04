//
//  FriendsTableViewHeader.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 11/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendsTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.clear
        
        applyTheme { [unowned self] theme in
            self.toolbar.themeForHeader(with: theme)
            self.rightLabel.textColor = theme.header.bar.content.color
            self.titleLabel.textColor = theme.header.bar.content.color
        }
    }
    
    func fill(with title: String, rightText: String) {
        titleLabel.text = title
        rightLabel.text = rightText
    }
}
