//
//  DropdownTransitionController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

protocol DropdownContainedControllerProtocol: class {
    var animationConstraint: NSLayoutConstraint! { get }
    var overlayView: UIView! { get }
    
    func closePressed()
}

class DropdownTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    private var isPresenting: Bool
    
    init(presenting: Bool) {
        isPresenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let inView = transitionContext.containerView
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return
        }
        
        if isPresenting {
            let toVCDropdown = DropdownNavigationController.containedController(from: toVC)!
            
            UIView.performWithoutAnimation {
                inView.addSubview(toVC.view)
                toVC.view.frame = inView.bounds
                
                toVCDropdown.animationConstraint.priority = UILayoutPriority(rawValue: 800)
                toVCDropdown.overlayView.alpha = 0
                
                toVC.view.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:  {
                toVCDropdown.overlayView.alpha = 1
                toVCDropdown.animationConstraint.priority = UILayoutPriority(rawValue: 250)
                toVC.view.layoutIfNeeded()
            }, completion: { _ in
                if transitionContext.transitionWasCancelled {
                    toVC.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        else {
            let fromVCDropdown = DropdownNavigationController.containedController(from: fromVC)!
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:  {
                fromVCDropdown.overlayView.alpha = 0
                fromVCDropdown.animationConstraint.priority = UILayoutPriority(rawValue: 800)
                fromVC.view.layoutIfNeeded()
            }, completion: { _ in
                if !transitionContext.transitionWasCancelled {
                    fromVC.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
