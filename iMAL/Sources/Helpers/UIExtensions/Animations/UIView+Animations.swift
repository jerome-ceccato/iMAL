//
//  UIView+Animations.swift
//
//  Created by Jérôme Ceccato on 17/12/2015.
//  Copyright © 2015 IATGOF. All rights reserved.
//

import UIKit

// MARK: - AnimationOptions
open class AnimationOptions {
    var animationOptions = UIViewAnimationOptions()
    var animationCurve: CAMediaTimingFunction?
    
    public convenience init(mediaTimingFunction: CAMediaTimingFunction, viewOptions: UIViewAnimationOptions = UIViewAnimationOptions()) {
        self.init()
        self.animationCurve = mediaTimingFunction
        self.animationOptions = viewOptions
    }
    
    public convenience init(curveControlPoints: String, viewOptions: UIViewAnimationOptions = UIViewAnimationOptions()) {
        self.init()
        self.animationCurve = timingFunctionFromControlPoints(curveControlPoints)
        self.animationOptions = viewOptions
    }
    
    public convenience init(viewOptions: UIViewAnimationOptions) {
        self.init()
        self.animationOptions = viewOptions
    }
    
    fileprivate func timingFunctionFromControlPoints(_ curveControlPoints: String) -> CAMediaTimingFunction? {
        let points = curveControlPoints.components(separatedBy: " ")

        if points.count == 4 {
            let p1 = Float(points[0]) ?? 0.0, p2 = Float(points[1]) ?? 0.0, p3 = Float(points[2]) ?? 0.0, p4 = Float(points[3]) ?? 0.0
            return CAMediaTimingFunction(controlPoints: p1, p2, p3, p4)
        }
        return nil
    }
    
    fileprivate func animationBlockForAnimations(_ animations: @escaping () -> Void) -> () -> Void {
        if let animationCurve = animationCurve {
            return {
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(animationCurve)
                animations()
                CATransaction.commit()
            }
        }
        return animations
    }
}

// MARK: - UIView+Animations
public extension UIView {
    public static func animationWithDuration(_ duration: TimeInterval, animationOptions: iMAL.AnimationOptions?, animations: @escaping () -> Void, completion: (() -> Void)?) {
        UIView.animate(withDuration: duration, delay: 0,
            options: animationOptions?.animationOptions ?? UIViewAnimationOptions(),
            animations: animationOptions != nil ? animationOptions!.animationBlockForAnimations(animations) : animations,
            completion: { _ in
                if let completion = completion {
                    completion()
                }
        })
    }
    
    public static func animationWithView(_ view: UIView?, duration: TimeInterval, animationOptions: iMAL.AnimationOptions?, animations: @escaping () -> Void, completion: (() -> Void)?) {
        if let view = view {
            UIView.transition(with: view, duration: duration,
                options: animationOptions?.animationOptions ?? UIViewAnimationOptions(),
                animations: animationOptions != nil ? animationOptions!.animationBlockForAnimations(animations) : animations,
                completion:  { _ in
                    if let completion = completion {
                        completion()
                    }
            })
        }
        else {
            animationWithDuration(duration, animationOptions: animationOptions, animations: animations)
        }
    }
    
    public static func animationWithDuration(_ duration: TimeInterval, animationOptions: iMAL.AnimationOptions?, animations: @escaping () -> Void) {
        animationWithDuration(duration, animationOptions: animationOptions, animations: animations, completion: nil)
    }
    
    public static func animationWithView(_ view: UIView?, duration: TimeInterval, animationOptions: iMAL.AnimationOptions?, animations: @escaping () -> Void) {
        animationWithView(view, duration: duration, animationOptions: animationOptions, animations: animations, completion: nil)
    }
}
