//
//  EditableDateEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 29/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableDateEntryView: EditableUserEntryView {
    
    var pickerView: UIDatePicker!
    
    enum DateType {
        case start
        case end
    }
    
    var type: DateType = .start
    
    override var coordinator: EntityEditingCoordinator! {
        didSet {
            pickerView = DynamicDatePickerView(dynamic: true)
            pickerView.datePickerMode = .date
            pickerView.date = Date()
            pickerView.maximumDate = Date()
            pickerView.addTarget(self, action: #selector(self.pickerDidUpdate), for: .valueChanged)
            
            textField.inputView = pickerView
        }
    }
    
    override var content: String? {
        didSet {
            if let content = content, let pickerView = pickerView, let date = content.asShortDateDisplayString {
                pickerView.date = date as Date
            }
        }
    }
    
    override func accessoryToolbar(with toolbar: UIToolbar) -> UIToolbar? {
        toolbar.items = [
            UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(self.removeDate)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Insert Today", style: .plain, target: self, action: #selector(self.insertToday))
        ]
        return toolbar
    }
}

// MARK: - Content
extension EditableDateEntryView {
    @objc func pickerDidUpdate() {
        textField.text = pickerView.date.shortDateDisplayString
        coordinator.updateDate(pickerView.date, type: type)
    }
    
    @objc func insertToday() {
        pickerView.date = Date()
        pickerDidUpdate()
    }
    
    @objc func removeDate() {
        textField.text = nil
        coordinator.updateDate(Date.nullDate, type: type)
    }
}
