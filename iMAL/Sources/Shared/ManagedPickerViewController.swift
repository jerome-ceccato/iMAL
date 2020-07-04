//
//  ManagedPickerViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class ManagedPickerViewController: RootViewController, ModalBottomViewControllerProtocol {
    @IBOutlet var overlayView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewHiddenConstraint: NSLayoutConstraint!
    
    @IBOutlet var toolbar: UIToolbar!

    @IBOutlet var pickerView: UIPickerView!
    
    private var data: [[String]] = []
    private var preSelectedIndexes: [Int]?
    private var completionHandler: ((Bool, [Int]) -> Void)!
    
    class func picker(withData data: [String], selectedIndex: Int?, completion: @escaping (Bool, Int) -> Void) -> ManagedPickerViewController? {
        return picker(withData: [data], selectedIndexes: selectedIndex.map { [$0] }, completion: { (success, indexes) in
            completion(success, indexes.first ?? 0)
        })
    }
    
    class func picker(withData data: [[String]], selectedIndexes: [Int]?, completion: @escaping (Bool, [Int]) -> Void) -> ManagedPickerViewController? {
        if let controller = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "ManagedPickerViewController") as? ManagedPickerViewController {
            
            controller.data = data
            controller.preSelectedIndexes = selectedIndexes
            controller.completionHandler = completion
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.modalPresentationStyle = .custom
            controller.transitioningDelegate = controller
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme { [unowned self] theme in
            self.toolbar.themeForPicker(with: theme)
            self.pickerView.reloadAllComponents()
        }
        
        if let indexes = preSelectedIndexes {
            indexes.enumerated().forEach {
                pickerView.selectRow($0.element, inComponent: $0.offset, animated: false)
            }
        }
    }
    
    func removeCancelButton() {
        let _ = view
        if let items = toolbar.items, items.count == 3 {
            toolbar.setItems(Array(items[1...]), animated: false)
        }
    }
}

// MARK: - Actions
extension ManagedPickerViewController {
    @IBAction func cancelPressed() {
        completionHandler?(false, (0 ..< pickerView.numberOfComponents).map { _ in 0 })
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed() {
        completionHandler(true, (0 ..< pickerView.numberOfComponents).map { pickerView.selectedRow(inComponent: $0) })
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Delegate
extension ManagedPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

// MARK: - UIViewControllerTransitioningDelegate
extension ManagedPickerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalBottomViewTransitionController(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalBottomViewTransitionController(presenting: false)
    }
}
