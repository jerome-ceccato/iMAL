//
//  EditableUserEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableUserEntryView: UIView, UITextFieldDelegate {
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var additionalRightLabel: UILabel?
    
    var coordinator: EntityEditingCoordinator!
    
    var content: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var additionalRightText: String? {
        get {
            return additionalRightLabel?.text
        }
        set {
            additionalRightLabel?.text = newValue
            if newValue == nil {
                additionalRightLabel?.removeFromSuperview()
                additionalRightLabel = nil
            }
        }
    }
    
    func accessoryToolbar(with toolbar: UIToolbar) -> UIToolbar? {
        return nil
    }
    
    // MARK: - Input accessory
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let width = AppDelegate.shared.viewPortSize.width
        let separatorView = SeparatorView(frame: CGRect(x: 0, y: 0, width: width, height: 1.0 / UIScreen.main.scale))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 44))

        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.detailsView.editableRegularBackground.color
            
            self.mainLabel.textColor = theme.detailsView.editableLabel.color
            self.textField.textColor = theme.detailsView.editableContent.color
            self.textField.keyboardAppearance = theme.global.keyboardStyle.style
            self.additionalRightLabel?.textColor = theme.detailsView.editableExtra.color
            
            separatorView.backgroundColor = theme.separators.pickers.color
            toolbar.themeForPicker(with: theme)
        }
        
        if let toolbar = accessoryToolbar(with: toolbar) {
            let containerView = UIView(frame: toolbar.bounds)
            containerView.backgroundColor = .clear
            containerView.addSubview(toolbar)
            containerView.addSubview(separatorView)
            textField.inputAccessoryView = containerView
        }
        else {
            textField.inputAccessoryView = separatorView
        }
    }

    // MARK: - Actions
    
    @IBAction func pressed() {
        textField.becomeFirstResponder()
    }
    
    // MARK: - TextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        backgroundColor = ThemeManager.currentTheme.detailsView.editableSelectedBackground.color
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        backgroundColor = ThemeManager.currentTheme.detailsView.editableRegularBackground.color
    }
}
