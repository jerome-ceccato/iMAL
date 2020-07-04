//
//  UIDevice+Platform.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 22/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

extension UIDevice {
    func platformDisplayString() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue) as String? ?? "?"
    }
    
    func isiPad() -> Bool {
        return userInterfaceIdiom == .pad
    }
}
