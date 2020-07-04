//
//  UILabel+Spacing.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 25/03/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

public extension UILabel {
    public func paragraphStyleWithSpacing(_ spacing: CGFloat) -> NSParagraphStyle {
        return NSAttributedString.paragraphStyleWithSpacing(spacing, alignment: textAlignment, breakMode: lineBreakMode)
    }
    
    public func setText(_ string: String, withLineSpacing lineSpacing: CGFloat, otherAttributes: [NSAttributedStringKey: AnyObject]? = nil) {
        attributedText = NSAttributedString(string: string, lineSpacing: lineSpacing, alignment: textAlignment, breakMode: lineBreakMode, otherAttributes: otherAttributes)
    }
}
