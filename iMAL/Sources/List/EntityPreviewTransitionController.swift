//
//  EntityPreviewTransitionController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityPreviewTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
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
        
        let contentContainerInitialTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        let options = AnimationOptions(curveControlPoints: "0.5 0 0.4 1")
        
        if isPresenting {
            let toVCPreview = toVC as! EntityPreviewProtocolAnimating
            
            let screenshot = screenShotView(inView)
            UIView.performWithoutAnimation {
                inView.addSubview(toVC.view)
                toVC.view.frame = inView.bounds
                
                toVCPreview.backgroundScreenshotView.image = screenshot
                toVCPreview.setupBlurOverlay()
                
                toVCPreview.backgroundScreenshotView.alpha = 0
                toVCPreview.contentContainerView.alpha = 0
                toVC.view.layoutIfNeeded()
                toVCPreview.contentContainerView.transform = contentContainerInitialTransform
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext) - 0.05, animations: {
                toVCPreview.backgroundScreenshotView.alpha = 1
            }) 
            UIView.animationWithDuration(transitionDuration(using: transitionContext), animationOptions: options, animations:  {
                toVCPreview.contentContainerView.alpha = 1
                toVCPreview.contentContainerView.transform = CGAffineTransform.identity
                }, completion: {
                    if transitionContext.transitionWasCancelled {
                        toVC.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        else {
            let fromVCPreview = fromVC as! EntityPreviewProtocolAnimating
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromVCPreview.backgroundScreenshotView.alpha = 0
            }) 
            UIView.animationWithDuration(transitionDuration(using: transitionContext), animationOptions: options, animations:  {
                fromVCPreview.contentContainerView.alpha = 0
                fromVCPreview.contentContainerView.transform = contentContainerInitialTransform
                }, completion: {
                    if !transitionContext.transitionWasCancelled {
                        fromVC.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

private extension EntityPreviewTransitionController {
    func screenShotView(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContext(view.frame.size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        view.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
