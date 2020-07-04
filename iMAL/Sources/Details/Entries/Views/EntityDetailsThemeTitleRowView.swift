//
//  EntityDetailsThemeTitleRowView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityDetailsThemeTitleRowView: UIView {
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.titleLabel.textColor = theme.detailsView.informationLabel.color
        }
    }
    
    class func build(with title: String) -> EntityDetailsThemeTitleRowView {
        let instance = Bundle.main.loadNibNamed("EntityDetailsThemeTitleRowView", owner: nil, options: nil)?.first as! EntityDetailsThemeTitleRowView
        
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.titleLabel.text = title + ":"
        
        return instance
    }
}
