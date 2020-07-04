//
//  SelectableTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class SelectableTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.clear
        
        applyTheme { [unowned self] _ in
            self.themeCellForHighlight(self.isSelected || self.isHighlighted)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        themeCellForHighlight(highlighted || isSelected)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        themeCellForHighlight(selected || isHighlighted)
    }
    
    func themeCellForHighlight(_ highlighted: Bool) {
        let theme = ThemeManager.currentTheme.global
        backgroundColor = highlighted ? theme.selectableCellHighlightedBackground.color : theme.selectableCellBackground.color
    }
}
