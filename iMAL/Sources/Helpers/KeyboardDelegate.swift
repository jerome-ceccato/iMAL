//
//  KeyboardDelegate.swift
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

public protocol KeyboardDelegate {
    func animateAlongSideKeyboardAnimation(appear: Bool, height: CGFloat)
}

public extension KeyboardDelegate where Self:UIViewController {
    
    /// Should be called on -viewWillAppear:
    public func configureKeyboard() {
        for name in [NSNotification.Name.UIKeyboardWillShow, NSNotification.Name.UIKeyboardWillHide] {
            NotificationCenter.register(self, name.rawValue) { [weak self] notif in
                self?.keyboardNotification(notif)
            }
        }
    }
    
    /// Should be called on -viewWillDisappear:
    public func unconfigureKeyboard() {
        for name in [NSNotification.Name.UIKeyboardWillShow, NSNotification.Name.UIKeyboardWillHide] {
            NotificationCenter.unregister(self, name.rawValue)
        }
    }
    
    private func keyboardNotification(_ notification: Notification) {
        guard let options = notification.userInfo else { return }
        
        let show = notification.name != NSNotification.Name.UIKeyboardWillHide
        let height = show ? (options[UIKeyboardFrameEndUserInfoKey] as AnyObject?)?.cgRectValue.size.height ?? 0 : 0
        
        let duration = (options[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let curveId = (options[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
        let curve = UIViewAnimationCurve(rawValue: curveId)

        UIView.animate(withDuration: duration, delay: 0.0, options: .layoutSubviews, animations: {
            if let curve = curve {
                UIView.setAnimationCurve(curve)
            }
            self.animateAlongSideKeyboardAnimation(appear: show, height: height)
        }, completion:nil)
    }
}
