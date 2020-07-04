//
//  TagEditViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 02/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class TagEditViewController: RootViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    
    var coordinator: EntityEditingCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        title = coordinator.changes.originalEntity.series.name
        textView.text = coordinator.changes.tags.joined(separator: ", ")
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelEditingPressed))
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveEditingPressed))
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            
            self.textView.textColor = theme.global.genericText.color
            self.textView.tintColor = theme.global.keyboardIndicator.color
            self.textView.keyboardAppearance = theme.global.keyboardStyle.style
            
            cancelButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.global.bars.content.color], for: .normal)
            saveButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.global.activeTint.color], for: .normal)
        }
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    @objc func cancelEditingPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func saveEditingPressed() {
        let tags = textView.text ?? ""
        coordinator.commitTagsChanges(tags, editController: self) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Editing
extension TagEditViewController: KeyboardDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unconfigureKeyboard()
    }
    
    func animateAlongSideKeyboardAnimation(appear: Bool, height: CGFloat) {
        textViewBottomConstraint.constant = max(0, height - bottomLayoutGuide.length)
    }
}
