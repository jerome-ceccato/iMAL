//
//  OptionsPopupTransitionController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 13/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol CustomPopupTransitioningTargetController {
    var overlayView: UIView! { get }
    var contentViewHiddenConstraint: NSLayoutConstraint! { get }
}

class CustomPopupTransitionController: NSObject {
    private var isPresenting: Bool
    private var transitionDuration: TimeInterval
    
    init(presenting: Bool, transitionDuration: TimeInterval = 0.5) {
        self.isPresenting = presenting
        self.transitionDuration = transitionDuration
    }
}

extension CustomPopupTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transitionCurve = "0.7 0 0.3 1"
        
        let inView = transitionContext.containerView
        if let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) {
            
            if isPresenting {
                if let actionVC = toVC as? CustomPopupTransitioningTargetController {
                    UIView.performWithoutAnimation {
                        inView.addSubview(toVC.view)
                        toVC.view.frame = inView.bounds
                        
                        actionVC.overlayView.alpha = 0
                        actionVC.contentViewHiddenConstraint.priority = UILayoutPriority.defaultHigh
                        toVC.view.layoutIfNeeded()
                    }
                    
                    UIView.animationWithDuration(
                        transitionDuration(using: transitionContext),
                        animationOptions: AnimationOptions(curveControlPoints: transitionCurve),
                        animations: {
                            actionVC.overlayView.alpha = 1
                            actionVC.contentViewHiddenConstraint.priority = UILayoutPriority.defaultLow - 1
                            toVC.view.layoutIfNeeded()
                        },
                        completion: {
                            if transitionContext.transitionWasCancelled {
                                toVC.view.removeFromSuperview()
                            }
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    })
                }
            }
            else {
                if let actionVC = fromVC as? CustomPopupTransitioningTargetController {
                    UIView.animationWithDuration(
                        transitionDuration(using: transitionContext),
                        animationOptions: AnimationOptions(curveControlPoints: transitionCurve),
                        animations:  {
                            actionVC.overlayView.alpha = 0
                            actionVC.contentViewHiddenConstraint.priority = UILayoutPriority.required - 1
                            fromVC.view.layoutIfNeeded()
                        },
                        completion:  {
                            if !transitionContext.transitionWasCancelled {
                                fromVC.view.removeFromSuperview()
                            }
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    })
                }
            }
        }
    }
}
