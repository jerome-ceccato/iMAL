//
//  UIColor+CustomColors.swift
//
//  Created by Jérôme Ceccato on 11/01/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public convenience init(hexValue: Int32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hexValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(hexValue & 0xFF) / 255.0,
            alpha: alpha)
    }
    
    private static let recognizedColorNames: [String: UIColor] = [
        "sblack": UIColor(hexValue: 0x252D33),
        "white": .white,
        "clear": .clear
    ]
    
    private typealias RGBComponents = (a: UInt32, r: UInt32, g: UInt32, b: UInt32)
    private typealias RGBComponentsF = (a: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat)
    
    private static func colorFromHexFormattedString(_ hexString: String) -> RGBComponents {
        let toScan = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var result = UInt32()
        Scanner(string: toScan).scanHexInt32(&result)
        
        let a, r, g, b: UInt32
        switch toScan.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, result >> 16, result >> 8 & 0xFF, result & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (result >> 24, result >> 16 & 0xFF, result >> 8 & 0xFF, result & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return (a, r, g, b)
    }
    
    private static func colorFromColorName(_ hexString: String) -> RGBComponentsF? {
        if let color = UIColor.recognizedColorNames[hexString.lowercased()] {
            var components: RGBComponentsF = (0, 0, 0, 0)
            color.getRed(&components.r, green: &components.g, blue: &components.b, alpha: &components.a)
            return components
        }
        return nil
    }
    
    private static func alphaFromPercent(string: String?) -> CGFloat? {
        if let content = string?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted), let value = Int(content) {
            return CGFloat(value) / 100
        }
        return nil
    }
    
    private convenience init(components: RGBComponents, alpha: CGFloat?) {
        self.init(red: CGFloat(components.r) / 255,
                  green: CGFloat(components.g) / 255,
                  blue: CGFloat(components.b) / 255,
                  alpha: alpha ?? (CGFloat(components.a) / 255))
    }
    
    private convenience init(componentsF: RGBComponentsF, alpha: CGFloat?) {
        self.init(red: componentsF.r,
                  green: componentsF.g,
                  blue: componentsF.b,
                  alpha: alpha ?? componentsF.a)
    }
    
    public convenience init(hexString: String) {
        let components = hexString.split(separator: " ")
        let alpha = UIColor.alphaFromPercent(string: components[safe: 1].flatMap { String($0) })
        let colorString = String(components[0])

        if let color = UIColor.colorFromColorName(colorString) {
            self.init(componentsF: color, alpha: alpha)
        }
        else {
            let components = UIColor.colorFromHexFormattedString(colorString)
            self.init(components: components, alpha: alpha)
        }
    }
    
    public convenience init?(optionalString: String) {
        let content = optionalString.lowercased()
        if content == "default" || content == "nil" {
            return nil
        }
        self.init(hexString: content)
    }
    
    public func asHexString() -> String {
        var components: RGBComponentsF = (0, 0, 0, 0)
        getRed(&components.r, green: &components.g, blue: &components.b, alpha: &components.a)
        return String(format: "#%02X%02X%02X", UInt(components.r * 255), UInt(components.g * 255), UInt(components.b * 255))
    }
    
    public func asRGBAHTMLString() -> String {
        var components: RGBComponentsF = (0, 0, 0, 0)
        getRed(&components.r, green: &components.g, blue: &components.b, alpha: &components.a)
        return String(format: "rgba(%u, %u, %u, %.2f)", UInt(components.r * 255), UInt(components.g * 255), UInt(components.b * 255), components.a)
    }
}
