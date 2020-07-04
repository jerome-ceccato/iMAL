//
//  ManagedActionSheetTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 19/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class ManagedActionSheetTableViewCell: SelectableTableViewCell, ManagedTableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    
    func fill(with data: Any, context: ManagedTableView.Context) {
        if let action = data as? ManagedActionSheetAction {
            titleLabel.text = action.title
            
            let theme = ThemeManager.currentTheme
            switch action.style {
            case .destructive:
                titleLabel.textColor = theme.global.destructiveButton.color
            case .done:
                titleLabel.textColor = theme.global.actionButton.color
            default:
                titleLabel.textColor = theme.actionPopup.text.color
            }
            
            switch action.height {
            case .default:
                titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            case .large:
                titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                
            }
            separatorView.isHidden = action.style != .separator
        }
    }
}
