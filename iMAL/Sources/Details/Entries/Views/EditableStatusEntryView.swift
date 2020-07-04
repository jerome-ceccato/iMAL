//
//  EditableStatusEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableStatusEntryView: EditableUserEntryView {

    var pickerView: EditableEntityPickerView!

    override var coordinator: EntityEditingCoordinator! {
        didSet {
            pickerView = EditableEntityPickerView(data: displayData, delegate: self)
            textField.inputView = pickerView
        }
    }
    
    override var content: String? {
        didSet {
            if let content = content, let pickerView = pickerView {
                pickerView.selectRow(displayData.index(of: content) ?? 0, inComponent: 0, animated: false)
            }
        }
    }
}

// MARK: - Content
extension EditableStatusEntryView: EditableEntityPickerDelegate {
    var displayData: [String] {
        return coordinator.statusDisplayStrings()
    }
    
    func pickerDidUpdate(_ picker: EditableEntityPickerView, selectedRow: Int) {
        let content = displayData[selectedRow]
        
        textField.text = content
        coordinator.updateStatus(withSelectedString: content)
    }
}
