//
//  EntityPreviewPickerView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 09/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityPreviewPickerView: UIView {
    private static let animationDuration: TimeInterval = 0.25
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var topToolbar: UIToolbar!
    
    private var data: [[String]] = []
    private var completionHandler: ((EntityPreviewPickerView, Bool, [Int]) -> Void)!
    private var bottomConstraint: NSLayoutConstraint?
    private var attachedControler: UIViewController?
    
    class func picker(withDisplayData data: [[String]], selectedIndexes: [Int]?, handler: @escaping (EntityPreviewPickerView, Bool, [Int]) -> Void) -> EntityPreviewPickerView? {
        if let picker = UINib(nibName: "EntityPreviewPickerView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? EntityPreviewPickerView {
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.setup(withData: data, selectedIndexes: selectedIndexes, handler: handler)
            return picker
        }
        return nil
    }
    
    func setup(withData data: [[String]], selectedIndexes: [Int]?, handler: @escaping (EntityPreviewPickerView, Bool, [Int]) -> Void) {
        self.data = data
        self.completionHandler = handler
        
        pickerView.reloadAllComponents()
        if let indexes = selectedIndexes {
            for (component, index) in indexes.enumerated() {
                pickerView.selectRow(index, inComponent: component, animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.topToolbar.themeForPicker(with: theme)
        }
    }
}

// MARK: - Animations
extension EntityPreviewPickerView {
    func animeAppear(in controller: UIViewController, animateAlongside: (() -> Void)?) {
        layoutIfNeeded()
        
        self.attachedControler = controller
        controller.view.addSubviewPinnedToEdges(self, insets: UIEdgeInsets(top: CGFloat.greatestFiniteMagnitude, left: 0, bottom: CGFloat.greatestFiniteMagnitude, right: 0))

        let constraintValue = self.bounds.height
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: controller.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: constraintValue)
        controller.view.addConstraint(bottomConstraint!)
        
        controller.view.layoutIfNeeded()
        UIView.animate(withDuration: EntityPreviewPickerView.animationDuration, animations: {
            self.bottomConstraint?.constant = 0
            
            animateAlongside?()
            controller.view.layoutIfNeeded()
        }) 
    }
    
    func animateDisappear(animateAlongside: (() -> Void)?, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: EntityPreviewPickerView.animationDuration,
            animations: {
                let constraintValue = self.bounds.height
                self.bottomConstraint?.constant = constraintValue
                
                animateAlongside?()
                self.superview?.layoutIfNeeded()
            },
            completion: { _ in
                self.removeFromSuperview()
                completion?()
            })
    }
}

// MARK: - Actions
extension EntityPreviewPickerView {
    @IBAction func cancelPressed() {
        completionHandler(self, false, [])
    }
    
    @IBAction func savePressed() {
        let selectedIndexes = (0 ..< pickerView.numberOfComponents).map { pickerView.selectedRow(inComponent: $0) }
        completionHandler(self, true, selectedIndexes)
    }
}

// MARK: - Delegate
extension EntityPreviewPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let theme = ThemeManager.currentTheme.picker
        return NSAttributedString(string: data[component][row], attributes: [NSAttributedStringKey.foregroundColor: theme.text.color])
    }
}
