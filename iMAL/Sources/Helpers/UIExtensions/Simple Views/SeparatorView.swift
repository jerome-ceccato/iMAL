//
//  SeparatorView.swift
//
//  Created by Jérôme Ceccato on 22/12/2015.
//  Copyright © 2015 IATGOF. All rights reserved.
//

import UIKit

open class SeparatorView: UIView {
    open override func awakeFromNib() {
        for constraint in constraints {
            if (constraint.firstAttribute == .height || constraint.firstAttribute == .width) && constraint.constant == 1 {
                constraint.constant = 1.0 / UIScreen.main.scale
            }
        }
    }
}

class HeavySeparatorView: SeparatorView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.separators.heavy.color
        }
    }
}

class LightSeparatorView: SeparatorView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.separators.light.color
        }
    }
}

class PickerSeparatorView: SeparatorView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.separators.pickers.color
        }
    }
}
