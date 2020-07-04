//
//  ManagedTableViewHeader.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class ManagedTableViewHeader: UITableViewHeaderFooterView {
    @IBInspectable var contentBackgroundColor: UIColor = UIColor.clear
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = contentBackgroundColor
    }
}
