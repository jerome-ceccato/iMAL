//
//  EntityDetailsThemeEntryRowView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityDetailsThemeEntryRowView: UIView {
    @IBOutlet var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.contentLabel.textColor = theme.detailsView.informationContent.color
        }
    }
    
    class func build(with content: String) -> EntityDetailsThemeEntryRowView {
        let instance = Bundle.main.loadNibNamed("EntityDetailsThemeEntryRowView", owner: nil, options: nil)?.first as! EntityDetailsThemeEntryRowView
        
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.contentLabel.text = content
        
        return instance
    }
}
