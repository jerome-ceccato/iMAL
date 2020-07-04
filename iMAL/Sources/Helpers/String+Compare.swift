//
//  String+Compare.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 05/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation

extension String {
    func compareSectionIndex(with y: String) -> Bool {
        let xName = self.lowercased(),
        yName = y.lowercased()
        let xStartWithLetter = String(xName[..<xName.index(xName.startIndex, offsetBy: 1)]).rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil,
        yStartWithLetter = String(yName[..<yName.index(yName.startIndex, offsetBy: 1)]).rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
        
        if xStartWithLetter == yStartWithLetter {
            return xName < yName
        }
        else if xStartWithLetter {
            return true
        }
        else {
            return false
        }
    }
}
