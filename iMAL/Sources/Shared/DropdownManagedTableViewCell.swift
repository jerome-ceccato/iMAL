//
//  DropdownManagedTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class DropdownManagedTableViewCell: UITableViewCell, ManagedTableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkImageView.image = #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
        backgroundColor = contentView.backgroundColor
        
        applyTheme { [unowned self] theme in
            self.checkImageView.tintColor = theme.dropdownPopup.checkmark.color
            self.setHighlighted(self.isHighlighted, animated: false)
            self.setSelected(self.isSelected, animated: false)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let theme = ThemeManager.currentTheme.dropdownPopup
        contentView.backgroundColor = highlighted ? theme.itemsSelectedBackground.color : theme.itemsRegularBackground.color
        backgroundColor = contentView.backgroundColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let theme = ThemeManager.currentTheme.dropdownPopup
        checkImageView.alpha = selected ? 1 : 0
        titleLabel.font = selected ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = selected ? theme.selectedText.color : theme.regularText.color
    }
    
    func fill(with data: Any, context: ManagedTableView.Context) {
        titleLabel.text = data as? String
    }
}
