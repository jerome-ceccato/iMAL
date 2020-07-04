//
//  SystemNewsTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 06/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class SystemNewsTableViewCell: SelectableTableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var unreadView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.titleLabel.textColor = theme.genericView.importantText.color
            self.dateLabel.textColor = theme.genericView.labelText.color
            self.unreadView.backgroundColor = theme.genericView.warningText.color
        }
    }
    
    func fill(with message: CommunicationMessage) {
        titleLabel.text = message.title
        unreadView.isHidden = message.viewed
        
        dateLabel.text = SharedFormatters.shortDateAndTimeDisplayFormatter.string(from: message.date as Date)
    }
}
