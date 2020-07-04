//
//  ModalBottomViewTransitionController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 19/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol ModalBottomViewControllerProtocol: class {
    var overlayView: UIView! { get }
    var contentView: UIView! { get }
    var contentViewHiddenConstraint: NSLayoutConstraint! { get }
}

class ModalBottomViewTransitionController: NSObject {
    var isPresenting: Bool
    var animationDuration: TimeInterval
    
    init(presenting: Bool, animationDuration: TimeInterval = 0.3) {
        self.isPresenting = presenting
        self.animationDuration = animationDuration
    }
}

extension ModalBottomViewTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transitionCurve = "0.7 0 0.3 1"
        
        let inView = transitionContext.containerView
        if let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) {
            
            if isPresenting {
                if let actionVC = toVC as? ModalBottomViewControllerProtocol {
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
                if let actionVC = fromVC as? ModalBottomViewControllerProtocol {
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
