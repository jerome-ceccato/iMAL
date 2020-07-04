//
//  CustomTabBarController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    static weak var shared: CustomTabBarController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CustomTabBarController.shared = self
        
        applyTheme { [unowned self] theme in
            self.tabBar.barTintColor = theme.global.bars.background.color
            self.tabBar.tintColor = theme.global.activeTint.color
        }
        
        delegate = self
        setupControllers()
        
        var active = Settings.homePageController
        if active == .last {
            active = Settings.lastActiveController
        }
        
        if active == .anime {
            selectedIndex = 0
        }
        else if active == .manga {
            selectedIndex = 1
        }
        
        updateMessages()
        Communication.handleMessagesUpdateNotification(self, update: { [weak self] in
            self?.updateMessages()
        })
        
        if #available(iOS 11, *) {
            view.accessibilityIgnoresInvertColors = true
        }
    }
    
    deinit {
        NotificationCenter.unregister(self)
        CustomTabBarController.shared = nil
    }
    
    private func updateMessages() {
        viewControllers?.last?.tabBarItem.badgeValue = Communication.unreadMessages > 0 ? "\(Communication.unreadMessages)" : nil
    }
    
    func setupControllers() {
        viewControllers = ["AnimeList", "MangaList", "Browse", "Friends", "Settings"].compactMap {
            UIStoryboard(name: $0, bundle: nil).instantiateInitialViewController()
        }
    }
    
    func dismissPresentedControllersIfNeeded(completion: @escaping () -> Void) {
        if presentedViewController != nil {
            dismiss(animated: true, completion: completion)
        }
        else {
            completion()
        }
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if selectedIndex == 0 {
            Settings.lastActiveController = .anime
        }
        else if selectedIndex == 1 {
            Settings.lastActiveController = .manga
        }
    }
}
