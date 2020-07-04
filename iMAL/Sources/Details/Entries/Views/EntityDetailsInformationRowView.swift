//
//  EntityDetailsInformationRowView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 28/01/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityDetailsInformationRowView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.titleLabel.textColor = theme.detailsView.informationLabel.color
            self.contentLabel.textColor = theme.detailsView.informationContent.color
        }
    }
    
    class func build(withTitle title: String, content: String) -> EntityDetailsInformationRowView {
        let instance = Bundle.main.loadNibNamed("EntityDetailsInformationRowView", owner: nil, options: nil)?.first as! EntityDetailsInformationRowView
        
        instance.translatesAutoresizingMaskIntoConstraints = false
        
        instance.titleLabel.text = title + ":"
        instance.contentLabel.text = content
        
        return instance
    }
}
