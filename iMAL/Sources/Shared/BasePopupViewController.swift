//
//  BasePopupViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class BasePopupViewController: RootViewController, CustomPopupTransitioningTargetController {
    @IBOutlet var overlayView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewHiddenConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
    }
    
    func setupModalTransitionStyle() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension BasePopupViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPopupTransitionController(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPopupTransitionController(presenting: false)
    }
}
