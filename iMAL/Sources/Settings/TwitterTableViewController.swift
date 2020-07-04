//
//  TwitterTableViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 31/12/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Social
import TwitterKit

class TwitterTableViewController: SettingsBaseTableViewController {
    @IBOutlet var twitterEnabledCheckImage: UIImageView!
    @IBOutlet var twitterActionsCheckImages: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter"
        
        let checkImage = #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
        twitterEnabledCheckImage.image = checkImage
        twitterActionsCheckImages.forEach { $0.image = checkImage }

        refreshContent()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if indexPath.section == 0 {
                self.toggleTwitterEnabled()
            }
            else {
                self.toggleTwitterAction(indexPath)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Actions
private extension TwitterTableViewController {
    func toggleTwitterEnabled() {
        let enabled = !Settings.twitterEnabled
        
        if enabled {
            if !SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                    if session != nil {
                        Settings.twitterEnabled = enabled
                        self.animateUpdate(view: self.twitterEnabledCheckImage, enabled: enabled)
                        self.updateTitle()
                    }
                })
            }
            else {
                Settings.twitterEnabled = enabled
                animateUpdate(view: twitterEnabledCheckImage, enabled: enabled)
                updateTitle()
            }
        }
        else {
            if let currentUser = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
                TWTRTwitter.sharedInstance().sessionStore.logOutUserID(currentUser)
            }
            Settings.twitterEnabled = enabled
            animateUpdate(view: twitterEnabledCheckImage, enabled: enabled)
            updateTitle()
        }
    }
    
    func toggleTwitterAction(_ indexPath: IndexPath) {
        let actionIndex = indexPath.row + 4 * (indexPath.section - 1)
        var actions = Settings.twitterActionsEnabled
        if let thisAction = Settings.TwitterAction(rawValue: actionIndex) {
            let enabled = !(actions[thisAction] ?? false)
            actions[thisAction] = enabled
            Settings.twitterActionsEnabled = actions
            animateUpdate(view: twitterActionsCheckImages[actionIndex], enabled: enabled)
        }
    }
    
    func refreshContent() {
        twitterEnabledCheckImage.alpha = Settings.twitterEnabled ? 1 : 0

        let actions = Settings.twitterActionsEnabled
        for (index, view) in twitterActionsCheckImages.enumerated() {
            if let thisAction = Settings.TwitterAction(rawValue: index) {
                view.alpha = (actions[thisAction] ?? false) ? 1 : 0
            }
        }
        updateTitle()
    }
    
    func updateTitle() {
        if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
            if let currentUser = session as? TWTRSession {
                title = "@" + currentUser.userName
            }
            // For some reason the cast fails after 3.3.0 and there is no other way to get the username
            else if let session = session as? NSObject, let name = session.value(forKey: "userName") as? String {
                title = "@" + name
            }
            else {
                title = "Twitter"
            }
        }
        else {
            title = "Twitter"
        }
    }
    
    func animateUpdate(view: UIView, enabled: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            view.alpha = enabled ? 1 : 0
        }) 
    }
}
