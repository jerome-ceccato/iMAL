//
//  ManagedDatePickerViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class ManagedDatePickerViewController: RootViewController, ModalBottomViewControllerProtocol {
    @IBOutlet var overlayView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewHiddenConstraint: NSLayoutConstraint!
    
    @IBOutlet var toolbar: UIToolbar!
    
    @IBOutlet var pickerView: UIDatePicker!
    
    private var setup: ((UIDatePicker) -> Void)!
    private var completionHandler: ((Date?) -> Void)!
    
    class func pickerWithSetup(setup: @escaping (UIDatePicker) -> Void, completion: @escaping (Date?) -> Void) -> ManagedDatePickerViewController? {
        if let controller = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "ManagedDatePickerViewController") as? ManagedDatePickerViewController {
            
            controller.setup = setup
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
        }
        
        setup(pickerView)
        setup = nil
    }
}

// MARK: - Actions
extension ManagedDatePickerViewController {
    @IBAction func cancelPressed() {
        completionHandler?(nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed() {
        completionHandler(pickerView.date)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ManagedDatePickerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalBottomViewTransitionController(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalBottomViewTransitionController(presenting: false)
    }
}
