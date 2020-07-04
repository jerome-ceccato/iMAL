//
//  SpacedLabel.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 25/03/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

open class SpacedLabel: UILabel {
    static let defaultKerning: CGFloat = 0
    static let defaultLineSpacing: CGFloat = NSParagraphStyle.default.lineSpacing
    
    @IBInspectable open var kerning: CGFloat = SpacedLabel.defaultKerning {
        didSet {
            refreshAttributes()
        }
    }
    
    @IBInspectable open var interlineSpacing: CGFloat = SpacedLabel.defaultLineSpacing {
        didSet {
            refreshAttributes()
        }
    }
    
    open override var text: String? {
        didSet {
            refreshAttributes()
        }
    }
    
    open override var font: UIFont? {
        didSet {
            refreshAttributes()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        refreshAttributes()
    }
    
    private func refreshAttributes() {
        var attributes: [NSAttributedStringKey: AnyObject] = [:]
        attributes[NSAttributedStringKey.font] = font
        if kerning > 0 {
            attributes[NSAttributedStringKey.kern] = kerning as AnyObject?
        }
        if interlineSpacing > 0 {
            attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyleWithSpacing(interlineSpacing)
        }
        attributedText = NSAttributedString(string: text ?? "", attributes: attributes)

    }
}
