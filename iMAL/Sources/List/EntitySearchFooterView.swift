//
//  EntitySearchFooterView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 16/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol EntitySearchFooterDelegate: class {
    func nextPagePressed()
}

class EntitySearchFooterView: UIView {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var nextPage: UIButton!
    @IBOutlet var loaderView: UIActivityIndicatorView!
    
    weak var delegate: EntitySearchFooterDelegate?
    var currentOperations: [NetworkRequestOperation] = []
    
    var entityName: String!
    
    var loadingIndicatorVisible: Bool {
        return loaderView.isAnimating && !loaderView.isHidden
    }
    
    class func footer(entityName: String, delegate: EntitySearchFooterDelegate) -> EntitySearchFooterView? {
        if let view = UINib(nibName: "EntitySearchFooterView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? EntitySearchFooterView {
            
            view.delegate = delegate
            view.setupView(entityName: entityName)
            return view
        }
        return nil
    }
    
    func setupView(entityName: String) {
        self.entityName = entityName
        
        showCharacterLimitLabel()
        nextPage.setTitle("Show more \(entityName)", for: UIControlState())
        
        applyTheme { [unowned self] theme in
            self.textLabel.textColor = theme.global.genericText.color
            self.nextPage.setTitleColor(theme.global.actionButton.color, for: .normal)
            self.loaderView.activityIndicatorViewStyle = theme.global.loadingIndicators.regular.style
        }
    }
}

// MARK: - Actions
extension EntitySearchFooterView {
    func showLoadingIndicator(_ show: Bool) {
        if show {
            loaderView.startAnimating()
            textLabel.isHidden = true
            nextPage.isHidden = true
        }
        else {
            loaderView.stopAnimating()
            textLabel.isHidden = false
            nextPage.isHidden = false
        }
    }
    
    func showCharacterLimitLabel() {
        textLabel.text = "You need to type at least 3 characters to search for new \(entityName!)."
        textLabel.alpha = 1
        nextPage.alpha = 0
    }
    
    func showNoResultsLabel() {
        textLabel.text = "No result."
        textLabel.alpha = 1
        nextPage.alpha = 0
    }
    
    func showNextPageButton() {
        textLabel.alpha = 0
        nextPage.alpha = 1
    }
    
    @IBAction func nextPagePressed() {
        delegate?.nextPagePressed()
    }
}

// MARK: - Loading
extension EntitySearchFooterView: NetworkLoading {
    func startLoading(_ operation: NetworkRequestOperation) {
        if currentOperations.count == 0 {
            showLoadingIndicator(true)
        }
        currentOperations.append(operation)
    }
    
    func stopLoading(_ operation: NetworkRequestOperation) {
        if let index = currentOperations.index(where: { $0 === operation }) {
            currentOperations.remove(at: index)
        }
        
        if currentOperations.count == 0 {
            showLoadingIndicator(false)
        }
    }
    
    func stopLoading(_ operation: NetworkRequestOperation, withError error: NSError, completion: @escaping () -> Void) {
        stopLoading(operation)
        completion()
    }
}
