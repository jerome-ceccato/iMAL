//
//  EntityRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct EntityHTMLRepresentation {
    static func htmlTemplate(withContent content: String, fontSize: Int = 15, color: UIColor) -> String {
        let linkColor = ThemeManager.currentTheme.global.link.color
        let container = "<div style=\"font-family: Helvetica; font-size: \(fontSize)px; color: \(color.asRGBAHTMLString()); a:link, a:visited, a:hover, a:active, a { color: \(linkColor.asHexString()) !important; text-decoration: none !important; }; \">%@</div>"
        return String(format: container, content)
    }
    
    static func colorLinks(forHTMLContent content: NSAttributedString) -> NSAttributedString {
        let linkColor = ThemeManager.currentTheme.global.link.color
        let newContent = NSMutableAttributedString(attributedString: content)
        content.enumerateAttributes(in: NSRange(0 ..< content.length), options: []) { (attributes, range, _) in
            for (attribute, _) in attributes {
                if attribute == NSAttributedStringKey.link {
                    newContent.addAttribute(NSAttributedStringKey.foregroundColor, value: linkColor, range: range)
                    newContent.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.clear, range: range)
                }
            }
        }
        return newContent
    }
}
