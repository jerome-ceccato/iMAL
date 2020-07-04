//
//  EditableEntityPickerView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol EditableEntityPickerDelegate: class {
    func pickerDidUpdate(_ picker: EditableEntityPickerView, selectedRow: Int)
}

class EditableEntityPickerView: DynamicPickerView {
    private(set) var displayData: [String] = []
    private weak var editingDelegate: EditableEntityPickerDelegate?
    
    convenience init(data: [String], delegate: EditableEntityPickerDelegate) {
        self.init(dynamic: true)
        
        self.displayData = data
        self.editingDelegate = delegate
        
        self.delegate = self
        self.dataSource = self
    }
}

extension EditableEntityPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let theme = ThemeManager.currentTheme.picker
        return NSAttributedString(string: displayData[row], attributes: [NSAttributedStringKey.foregroundColor: theme.text.color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editingDelegate?.pickerDidUpdate(self, selectedRow: row)
    }
}
