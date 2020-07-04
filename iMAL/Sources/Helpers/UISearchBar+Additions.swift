//
//  UISearchBar+Additions.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 10/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

extension UISearchBar {
    func setSearchFieldBackgroundImage(withColor color: UIColor) {
        let image = UIImage.roundedImage(UIImage.image(withColor: color, size: CGSize(width: 28, height: 28)), cornerRadius: 8)
        setSearchFieldBackgroundImage(image, for: UIControlState())
        searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
    }
    
    func setSearchFieldTextColor(_ color: UIColor) {
        if let textField = getFirstTextField(self) {
            textField.textColor = color
        }
    }
}

private func getFirstTextField(_ view: UIView) -> UITextField? {
    if let textField = view as? UITextField {
        return textField
    }
    
    for v in view.subviews {
        if let textField = getFirstTextField(v) {
            return textField
        }
    }
    return nil
}
