//
//  UserEntityAttributedRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct UserEntityAttributedRepresentation {
    static func attributedDisplayString(forScore score: Int) -> NSAttributedString {
        let scoreMainColor = ThemeManager.currentTheme.entity.label.color
        let scoreHighlightedColor = ThemeManager.currentTheme.entity.score.color
        let attributedScore = NSMutableAttributedString(string: "Score: ", attributes: [NSAttributedStringKey.foregroundColor: scoreMainColor])
        if score > 0 {
            attributedScore.append(NSAttributedString(string: "\(score)", attributes: [NSAttributedStringKey.foregroundColor: scoreHighlightedColor]))
        }
        else {
            attributedScore.append(NSAttributedString(string: "-", attributes: [NSAttributedStringKey.foregroundColor: scoreMainColor]))
        }
        return attributedScore
    }
    
    static func attributedCounter(withCurrent current: Int, total: Int, prefix: String = "", suffix: String = "", fontSize: CGFloat = 17) -> NSAttributedString {
        let regularColor = ThemeManager.currentTheme.entity.label.color
        let regularFont = UIFont.systemFont(ofSize: fontSize)
        let regularAttributes = [NSAttributedStringKey.foregroundColor: regularColor, NSAttributedStringKey.font: regularFont]
        
        let highlightedColor = ThemeManager.currentTheme.entity.metrics.color
        let highlightedFont = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        let highlightedAttributes = [NSAttributedStringKey.foregroundColor: highlightedColor, NSAttributedStringKey.font: highlightedFont]
        
        let string = NSMutableAttributedString(string: prefix, attributes: regularAttributes)
        
        if (!prefix.isEmpty || !suffix.isEmpty) && current == 0 {
            let totalString = total > 0 ? "\(total)" : "?"
            string.append(NSAttributedString(string: "\(totalString)\(suffix)", attributes: regularAttributes))
        }
        else {
            string.append(NSAttributedString(string: "\(current)", attributes: highlightedAttributes))
            
            if prefix.isEmpty && !suffix.isEmpty && total == 0 {
                string.append(NSAttributedString(string: suffix, attributes: regularAttributes))
            }
            else if total > 0 || prefix.isEmpty {
                string.append(NSAttributedString(string: " / \(total)", attributes: regularAttributes))
            }
        }
        
        return string
    }
}
