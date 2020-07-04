//
//  NSAttributedString+Spacing.swift
//
//  Created by Jérôme Ceccato on 25/03/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

public extension NSAttributedString {
    public static func paragraphStyleWithSpacing(_ spacing: CGFloat, alignment: NSTextAlignment = .natural, breakMode: NSLineBreakMode = .byWordWrapping) -> NSParagraphStyle {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.lineSpacing = spacing
        style.alignment = alignment
        style.lineBreakMode = breakMode
        return style
    }
    
    public convenience init(string: String, lineSpacing: CGFloat, alignment: NSTextAlignment = .natural, breakMode: NSLineBreakMode = .byWordWrapping, otherAttributes: [NSAttributedStringKey: AnyObject]? = nil) {
        var attributes = otherAttributes ?? [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.paragraphStyle] = NSAttributedString.paragraphStyleWithSpacing(lineSpacing, alignment: alignment, breakMode: breakMode)
        self.init(string:string, attributes: attributes)
    }
}
