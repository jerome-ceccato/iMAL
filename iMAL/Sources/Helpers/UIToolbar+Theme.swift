//
//  UIToolbar+Theme.swift
//  iMAL
//
//  Created by Jerome Ceccato on 07/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

extension UIToolbar {
    func themeForPicker(with theme: Theme) {
        self.barStyle = theme.global.bars.style.barStyle
        self.isTranslucent = true
        self.barTintColor = UIColor.clear
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.tintColor = theme.global.activeTint.color
        self.backgroundColor = theme.picker.background.color
    }
    
    func themeForHeader(with theme: Theme) {
        self.barStyle = theme.header.bar.style.barStyle
        self.barTintColor = theme.header.bar.background.color
    }
}
