//
//  CustomNavigationController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 21/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    class func controller(withRootController rootController: UIViewController?) -> CustomNavigationController? {
        if let controller = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "CustomNavigationController") as? CustomNavigationController {
            if let root = rootController {
                controller.viewControllers = [root]
            }
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) {
            view.accessibilityIgnoresInvertColors = true
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.navigationBar.barStyle = theme.global.bars.style.barStyle
            self.navigationBar.barTintColor = theme.global.bars.background.color
            self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.global.bars.title.color]
            self.navigationBar.tintColor = theme.global.bars.content.color
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.currentTheme.global.statusBar.style
    }
    
    private func hideShadowSeparatorView() {
        hideShadowSeparatorView(from: navigationBar)
    }
    
    private func hideShadowSeparatorView(from view: UIView) {
        if view.bounds.height <= 1, let view = view as? UIImageView {
            view.alpha = 0
            view.backgroundColor = UIColor.clear
            view.image = UIImage()
            view.isHidden = true
        }
        
        for v in view.subviews {
            hideShadowSeparatorView(from: v)
        }
    }
}
