//
//  DynamicPickerView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 04/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class DynamicPickerView: UIPickerView {
    func setupTheme() {
        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.picker.background.color
            self.reloadAllComponents()
        }
    }
    
    convenience init(dynamic: Bool) {
        self.init()
        
        if dynamic {
            setupTheme()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTheme()
    }
}

class DynamicDatePickerView: UIDatePicker {
    func setupTheme() {
        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.picker.background.color
            self.setValue(theme.picker.text.color, forKey: "textColor")
        }
    }
    
    convenience init(dynamic: Bool) {
        self.init()
        
        if dynamic {
            setupTheme()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTheme()
    }
}
