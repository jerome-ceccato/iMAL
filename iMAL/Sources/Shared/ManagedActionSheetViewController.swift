//
//  ManagedActionSheetViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 19/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class ManagedActionSheetAction {
    enum Style {
        case `default`
        case destructive
        case done
        case separator
    }
    
    enum Height {
        case `default`
        case large
    }
    
    var title: String
    var style: Style
    var action: (() -> Void)?
    var height: Height
    
    init(title: String, style: Style, height: Height = .default, action: (() -> Void)?) {
        self.title = title
        self.style = style
        self.height = height
        self.action = action
    }
    
    var requiredHeight: CGFloat {
        switch style {
        case .separator:
            return 10
        default:
            switch height {
            case .default:
                return 44
            case .large:
                return 64
            }
        }
    }
}

class ManagedActionSheetViewController: RootViewController, ModalBottomViewControllerProtocol {
    @IBOutlet var overlayView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewHiddenConstraint: NSLayoutConstraint!
    
    @IBOutlet var tableView: ManagedTableView!
    @IBOutlet var titleLabel: UILabel!
    
    private var actionSheetTitle: String?
    private var data: [ManagedActionSheetAction] = []
    
    var cancelCompletion: (() -> Void)?
    
    class func actionSheet(withTitle title: String?) -> ManagedActionSheetViewController? {
        if let controller = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "ManagedActionSheetViewController") as? ManagedActionSheetViewController {
            
            controller.actionSheetTitle = title
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.modalPresentationStyle = .custom
            controller.transitioningDelegate = controller
            
            return controller
        }
        return nil
    }
    
    func addAction(_ action: ManagedActionSheetAction) {
        data.append(action)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = actionSheetTitle
        
        tableView.setup(withData: [(section: nil, items: data)],
                                heightForItem: { item in (item as! ManagedActionSheetAction).requiredHeight },
                                selectAction: { [weak self] item in self?.actionPressed(item as! ManagedActionSheetAction) })
        
        tableView.manageScrollAutomatically = true
        
        applyTheme { [unowned self] theme in
            self.tableView.backgroundColor = theme.actionPopup.background.color
            self.overlayView.backgroundColor = theme.actionPopup.overlay.color
            self.contentView.backgroundColor = theme.actionPopup.background.color
            self.titleLabel.textColor = theme.actionPopup.title.color
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.isScrollEnabled = floor(tableView.height) > floor(tableView.bounds.height)
    }
}

// MARK: - Actions
extension ManagedActionSheetViewController {
    @IBAction func cancelPressed() {
        dismiss(animated: true, completion: cancelCompletion)
    }
    
    func actionPressed(_ action: ManagedActionSheetAction) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: action.action)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ManagedActionSheetViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalBottomViewTransitionController(presenting: true, animationDuration: 0.2)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalBottomViewTransitionController(presenting: false, animationDuration: 0.2)
    }
}
