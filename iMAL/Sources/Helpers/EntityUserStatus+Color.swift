//
//  EntityUserStatus+Color.swift
//  iMAL
//
//  Created by Jerome Ceccato on 14/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

extension EntityUserStatus {
    func colorCode() -> UIColor {
        let theme = ThemeManager.currentTheme
        switch self {
        case .watching:
            return theme.colorCode.watching.color
        case .completed:
            return theme.colorCode.completed.color
        case .onHold:
            return theme.colorCode.onHold.color
        case .dropped:
            return theme.colorCode.dropped.color
        case .planToWatch:
            return theme.colorCode.planToWatch.color
        default:
            return theme.global.genericText.color
        }
    }
}
