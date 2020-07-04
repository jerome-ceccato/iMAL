//
//  UIView+Autolayout.swift
//
//  Created by Jérôme Ceccato on 23/12/2015.
//  Copyright © 2015 IATGOF. All rights reserved.
//

import UIKit

public extension UIView {
    
    public convenience init(autolayout: Bool) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = !autolayout
    }
    
    @discardableResult
    public func centerSubviewVerticaly(_ view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: offset)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    public func centerSubviewHorizontaly(_ view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: offset)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    public func centerSubview(_ view: UIView, offset: CGFloat = 0) -> [NSLayoutConstraint] {
        return [centerSubviewVerticaly(view, offset: offset), centerSubviewHorizontaly(view, offset: offset)]
    }
    
    @discardableResult
    public func addConstraintsWithVisualFormats(_ formats: [String], metrics: [String: AnyObject]? = nil, views: [String: AnyObject]) -> [NSLayoutConstraint] {
        var allConstraints: [NSLayoutConstraint] = []
        for fmt in formats {
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: fmt, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
            self.addConstraints(constraints)
            allConstraints.append(contentsOf: constraints)
        }
        return constraints
    }
    
    @discardableResult
    public func addSubviewPinnedToEdges(_ view: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero) -> [NSLayoutConstraint] {
        self.addSubview(view)
        
        let metrics = ["left": insets.left,
            "right": insets.right,
            "top": insets.top,
            "bottom": insets.bottom]
        let views = ["view": view]

        let leftInset = insets.left == CGFloat.greatestFiniteMagnitude ? "" : "|-left-"
        let rightInset = insets.right == CGFloat.greatestFiniteMagnitude ? "" : "-right-|"
        let topInset = insets.top == CGFloat.greatestFiniteMagnitude ? "" : "|-top-"
        let bottomInset = insets.bottom == CGFloat.greatestFiniteMagnitude ? "" : "-bottom-|"
        
        return addConstraintsWithVisualFormats(["H:\(leftInset)[view]\(rightInset)", "V:\(topInset)[view]\(bottomInset)"], metrics: metrics as [String : AnyObject]?, views: views)
    }
    
    @discardableResult
    public func addConstraintForHeight(_ height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
        addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    public func addConstraintForWidth(_ width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    public func addConstraintsForSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return [addConstraintForWidth(size.width), addConstraintForHeight(size.height)]
    }
    
    @discardableResult
    public func makeWidthEqualToWidthOfView(_ view: UIView) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        (view.superview == self.superview ? self.superview : self)?.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    public func makeHeightEqualToHeightOfView(_ view: UIView) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0)
        (view.superview == self.superview ? self.superview : self)?.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    public func makeSizeEqualToSizeOfView(_ view: UIView) -> [NSLayoutConstraint] {
        return [makeWidthEqualToWidthOfView(view), makeHeightEqualToHeightOfView(view)]
    }
    
    @discardableResult
    public func makeAttribute(_ attribute: NSLayoutAttribute, equalToAttribute otherAttribute: NSLayoutAttribute, ofView view: AnyObject, withConstant constant: CGFloat = 0, withMultiplier multiplier: CGFloat = 1) -> NSLayoutConstraint {
        let constraint = createAttribute(attribute, equalToAttribute: otherAttribute, ofView: view, withConstant: constant, withMultiplier: multiplier)
        if ((attribute == .width || attribute == .height) && (superview != view.superview)) || superview == nil {
            addConstraint(constraint)
        }
        else {
            superview!.addConstraint(constraint)
        }
        return constraint
    }

    public func createAttribute(_ attribute: NSLayoutAttribute, equalToAttribute otherAttribute: NSLayoutAttribute, ofView view: AnyObject, withConstant constant: CGFloat = 0, withMultiplier multiplier: CGFloat = 1) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view, attribute: otherAttribute, multiplier: multiplier, constant: constant)
    }
}
