//
//  EntityPreviewActionTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityPreviewAction {
    var title: String
    var destructive: Bool
    var action: () -> Void
    
    init(title: String, destructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.destructive = destructive
        self.action = action
    }
}

class EntityPreviewActionTableViewCell: SelectableTableViewCell, ManagedTableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var separatorView: UIView!
        
    func fill(with data: Any, context: ManagedTableView.Context) {
        if let data = data as? EntityPreviewAction {
            let theme = ThemeManager.currentTheme.global
            
            titleLabel.text = data.title
            titleLabel.textColor = data.destructive ? theme.destructiveButton.color : theme.actionButton.color
        }
        separatorView.isHidden = (context.indexPath.row + 1) >= context.data[context.indexPath.section].items.count
    }
}
