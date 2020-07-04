//
//  FooterCollectionViewFlowLayout.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/09/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class FooterCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var _globalFooterView: UIView?
    var globalFooterView: UIView? {
        get {
            return _globalFooterView
        }
        set {
            if _globalFooterView != nil {
                if let currentFooter = _globalFooterView as? UILabel, let newFooter = newValue as? UILabel {
                    currentFooter.text = newFooter.text
                }
                else {
                    _globalFooterView?.removeFromSuperview()
                    _globalFooterView = newValue
                    invalidateLayout()
                }
            }
            else {
                _globalFooterView = newValue
                invalidateLayout()
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        var currentSize = super.collectionViewContentSize
        currentSize.height += globalFooterView?.bounds.height ?? 0
        return currentSize
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        if let footer = globalFooterView {
            footer.frame.origin = CGPoint(x: 0, y: collectionViewContentSize.height - footer.bounds.height)
            if footer.superview == nil {
                collectionView?.addSubview(footer)
            }
        }
    }
}
