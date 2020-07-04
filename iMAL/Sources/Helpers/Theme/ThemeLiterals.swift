//
//  ThemeLiterals.swift
//  iMAL
//
//  Created by Jerome Ceccato on 24/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class ThemeLiteral: Codable {
    var literal: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(literal)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        literal = try container.decode(String.self)
    }
}

extension Theme {
    class OptionalColor: ThemeLiteral {
        var color: UIColor? {
            return UIColor(optionalString: literal)
        }
    }
    
    class Color: ThemeLiteral {
        var color: UIColor {
            return UIColor(hexString: literal)
        }
    }
    
    class BarStyle: ThemeLiteral {
        var barStyle: UIBarStyle {
            switch literal {
            case "black":
                return .black
            default:
                return .default
            }
        }
    }
    
    class StatusBarStyle: ThemeLiteral {
        var style: UIStatusBarStyle {
            switch literal {
            case "light", "lightContent":
                return .lightContent
            default:
                return .default
            }
        }
    }
    
    class ScrollIndicator: ThemeLiteral {
        var style: UIScrollViewIndicatorStyle {
            switch literal {
            case "white":
                return .white
            default:
                return .default
            }
        }
    }
    
    class LoadingIndicator: ThemeLiteral {
        var style: UIActivityIndicatorViewStyle {
            switch literal {
            case "white":
                return .white
            case "large", "whiteLarge":
                return .whiteLarge
            default:
                return .gray
            }
        }
    }
    
    class KeyboardStyle: ThemeLiteral {
        var style: UIKeyboardAppearance {
            switch literal {
            case "dark", "black":
                return .dark
            case "light", "white":
                return .light
            default:
                return .default
            }
        }
    }
    
    class BlurStyle: ThemeLiteral {
        var style: UIBlurEffectStyle {
            switch literal {
            case "dark":
                return .dark
            case "light":
                return .light
            case "extraLight", "extralight", "xlight":
                return .extraLight
            default:
               return .dark
            }
        }
    }
}
