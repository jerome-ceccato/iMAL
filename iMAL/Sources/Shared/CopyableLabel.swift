//
//  CopyableLabel.swift
//  iMAL
//
//  Created by Jerome Ceccato on 24/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class CopyableLabel: UILabel {
    @IBInspectable var preferredMenuArrowDirection: String? = nil
    
    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.showMenu(sender:))))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.arrowDirection = arrowDirection(for: preferredMenuArrowDirection)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    private func arrowDirection(for string: String?) -> UIMenuControllerArrowDirection {
        if let string = string {
            return ["up": .up, "down": .down, "right": .right, "left": .left][string] ?? .down
        }
        return .down
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
}
