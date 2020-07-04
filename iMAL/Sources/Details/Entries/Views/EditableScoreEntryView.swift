//
//  EditableScoreEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableScoreEntryView: EditableUserEntryView {
    
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
extension EditableScoreEntryView: EditableEntityPickerDelegate {
    var displayData: [String] {
        return coordinator.scoreDisplayStrings()
    }
    
    func pickerDidUpdate(_ picker: EditableEntityPickerView, selectedRow: Int) {
        textField.text = displayData[selectedRow]
        coordinator.updateScore(selectedRow)
    }
}
