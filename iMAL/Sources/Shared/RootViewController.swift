//
//  RootViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Toast_Swift

protocol NetworkLoadingController: NetworkLoading {
    var view: UIView! { get }
}

class RootViewController: UIViewController {
    var currentOperations = [NetworkRequestOperation]()
    var loaderIsVisible = false
    var loaderContainerView: UIView {
        return self.view
    }
    
    func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        return ErrorCenter.messageForNetworkError(error)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.currentTheme.global.statusBar.style
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
            view.accessibilityIgnoresInvertColors = true
        }
        
        applyTheme { [unowned self] _ in
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackView()
    }
    
    private func trackView() {
        if let identifier = analyticsIdentifier {
            Analytics.track(view: identifier)
        }
    }
    
    var analyticsIdentifier: Analytics.View? {
        return nil
    }
}

// MARK: - Entity presenting
enum EntityPresentingContext {
    case myList
    case other
}

extension RootViewController {
    func shouldInvertTap(context: EntityPresentingContext) -> Bool {
        switch context {
        case .myList:
            return Settings.invertTapGesturesOnMyList
        case .other:
            return Settings.invertTapGesturesOnOthers
        }
    }
    
    func showEntityDetails(entity: Entity, alternativeAction: Bool = false, context: EntityPresentingContext = .other) {
        if alternativeAction != shouldInvertTap(context: context) {
            pushEntityDetailsViewController(for: entity)
        }
        else {
            presentEntityPreviewViewController(for: entity)
        }
    }
    
    func pushEntityDetailsViewController(for entity: Entity) {
        if let controller = EntityDetailsViewController.controller(for: entity) {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func presentEntityPreviewViewController(for entity: Entity) {
        if let controller = EntityPreviewViewController.preview(for: entity, delegate: self) {
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - Actions
extension RootViewController {
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Network loading
extension RootViewController: NetworkLoadingController {
    func showLoaderView(_ show: Bool) {
        if show {
            loaderContainerView.makeToastActivity(.center)
            loaderIsVisible = true
        }
        else {
            loaderContainerView.hideToastActivity()
            loaderIsVisible = false
        }
    }
    
    func showError(_ error: NSError, context: NetworkRequestOperation, completion: (() -> Void)?) {
        if let message = messageForNetworkError(error) {
            ErrorCenter.present(error: message, from: self, context: ErrorCenter.Context(controller: self, error: error, networkOperation: context, completion: completion))
        }
        else {
            completion?()
        }
    }
    
    func startLoading(_ operation: NetworkRequestOperation) {
        if !loaderIsVisible {
            showLoaderView(true)
        }
        currentOperations.append(operation)
    }
    
    func stopLoading(_ operation: NetworkRequestOperation) {
        if let index = currentOperations.index(where: { $0 === operation }) {
            currentOperations.remove(at: index)
        }
        
        if currentOperations.isEmpty {
            showLoaderView(false)
        }
    }
    
    func stopLoading(_ operation: NetworkRequestOperation, withError error: NSError, completion: @escaping () -> Void) {
        stopLoading(operation)
        showError(error, context: operation, completion: completion)
    }
}
