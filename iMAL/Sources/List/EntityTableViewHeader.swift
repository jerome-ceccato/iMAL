//
//  EntityTableViewHeader.swift
//  iMAL
//
//  Created by Jerome Ceccato on 22/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

enum EntityHeaderContext {
    case list(expanded: Bool)
    case schedule(expanded: Bool)
    case friendlist(expanded: Bool)
    case search(expanded: Bool)
}

class EntityTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    private var section: Int = 0
    private var action: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.clear
        
        applyTheme { [unowned self] theme in
            self.toolbar.themeForHeader(with: theme)
            self.rightLabel.textColor = theme.header.bar.content.color
        }
    }
    
    func fill(withSection section: Int, title: String, rightText: String, context: EntityHeaderContext, pressedAction: ((Int) -> Void)?) {
        self.section = section
        self.action = pressedAction
        
        rightLabel.text = rightText
    
        let headerTheme = ThemeManager.currentTheme.header
        let titleContent = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: headerTheme.bar.content.color])
        switch context {
        case .list(let expanded), .schedule(let expanded), .friendlist(let expanded):
            if !expanded {
                titleContent.append(NSAttributedString(string: " (closed)", attributes: [NSAttributedStringKey.foregroundColor: headerTheme.closedIndicator.color, NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 14)]))
            }
        case .search(let expanded):
            if !expanded {
                titleContent.append(NSAttributedString(string: " (tap to open)", attributes: [NSAttributedStringKey.foregroundColor: headerTheme.tapToOpenIndicator.color, NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 14)]))
            }
        }
        
        titleLabel.attributedText = titleContent
    }
    
    @IBAction func headerPressed() {
        action?(section)
    }
}
