//
//  SettingsTableViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import AlamofireImage

class SettingsTableViewController: SettingsBaseTableViewController {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var unreadNewsLabel: UILabel!
    @IBOutlet var cacheAmountLabel: UILabel!
    @IBOutlet var twitterEnabledCheckImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        let checkImage = #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
        twitterEnabledCheckImage.image = checkImage
        
        setupBetaIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameLabel.text = CurrentUser.me.currentUsername
        unreadNewsLabel.text = Communication.unreadMessages > 0 ? "\(Communication.unreadMessages) unread news" : nil
        twitterEnabledCheckImage.alpha = Settings.twitterEnabled ? 1 : 0
        
        refreshCacheUsage()
    }
    
    private func refreshCacheUsage() {
        let cacheMB = Double(ImageDownloader.defaultURLCache().currentDiskUsage) / Double(1_000_000)
        cacheAmountLabel.text = String(format: "%.1f MB", cacheMB)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track(view: .settings)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actions: [[(IndexPath) -> Void]] = [
            [self.userPressed],
            [self.viewAllNews, self.feedbackPressed, self.trelloPressed, self.discordPressed],
            [self.customizePressed],
            [self.twitterPressed],
            [self.exportPressed, self.doNothing, self.removeCachePressed],
            [self.aboutPressed]
        ]
        
        DispatchQueue.main.async {
            actions[safe: indexPath.section]?[safe: indexPath.row]?(indexPath)
        }
    }
}

// MARK: - Actions
private extension SettingsTableViewController {
    func doNothing(_ indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func userPressed(_ indexPath: IndexPath) {
        if let homeController = CustomTabBarController.shared {
            if let loginController = LoginViewController.controllerWithCurrentRootController(homeController) {
                present(loginController, animated: true) {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                return
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func feedbackPressed(_ indexPath: IndexPath) {
        EmailSender.sendEmail(from: self, title: "[iMAL][Feedback]", content: EmailSender.regularMailContent()) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func trelloPressed(_ indexPath: IndexPath) {
        URL(string: Global.trelloBoardURL)?.open(in: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func discordPressed(_ indexPath: IndexPath) {
        if let url = URL(string: Global.discordURL) {
            UIApplication.shared.openURL(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func customizePressed(_ indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SettingsAppTableViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.3) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func twitterPressed(_ indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "TwitterTableViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.3) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func aboutPressed(_ indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AboutTableViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.3) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func viewAllNews(_ indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SystemNewsTableViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.3) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func exportPressed(_ indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SettingsExportTableViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.3) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func removeCachePressed(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to remove all cached data?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in self.doRemoveCache() }))
        present(alert, animated: true) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func doRemoveCache() {
        let cache = ImageDownloader.defaultURLCache()

        let memoryMax = cache.memoryCapacity
        let diskMax = cache.diskCapacity
        
        cache.removeAllCachedResponses()
        cache.memoryCapacity = 0
        cache.diskCapacity = 0
        
        cache.memoryCapacity = memoryMax
        cache.diskCapacity = diskMax
        
        AiringNotificationsCenter.shared.cleanupImageCache()
        Database.shared.clearAiringDataCache()
        UserDataCache.clear()
        
        cacheAmountLabel.text = "0 MB"
        delay(1) {
            self.refreshCacheUsage()
        }
    }
}

extension SettingsTableViewController {
    private func setupBetaIfNeeded() {
        #if DEVELOPMENT_BUILD
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Beta", style: .plain, target: self, action: #selector(self.betaPressed))
        #endif
    }
    
    #if DEVELOPMENT_BUILD
    @objc func betaPressed() {
        BetaInformationsViewController.present(in: self)
    }
    #endif
}
