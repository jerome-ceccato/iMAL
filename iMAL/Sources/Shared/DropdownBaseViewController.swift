//
//  DropdownBaseViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class DropdownBaseViewController: RootViewController, DropdownContainedControllerProtocol {
    @IBOutlet var animationConstraint: NSLayoutConstraint!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var overlayView: UIView!
    
    func setupModalTransitioning() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        navigationController?.modalPresentationStyle = .custom
        navigationController?.transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        applyTheme { [unowned self] theme in
            self.contentView.backgroundColor = theme.dropdownPopup.background.color
            self.overlayView.backgroundColor = theme.dropdownPopup.overlay.color
        }
    }
    
    func closePressed() {
        
    }
}

extension DropdownBaseViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DropdownTransitionController(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DropdownTransitionController(presenting: false)
    }
}
