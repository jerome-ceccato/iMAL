//
//  SystemNewsDetailsViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 06/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class SystemNewsDetailsViewController: RootViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    var message: CommunicationMessage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = message.title
        messageLabel.text = message.message
        
        Communication.markMessageAsRead(message)
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.titleLabel.textColor = theme.genericView.importantText.color
            self.messageLabel.textColor = theme.genericView.importantText.color
        }
    }
}
