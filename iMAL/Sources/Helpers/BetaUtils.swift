//
//  BetaUtils.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/04/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation

struct BetaUtils {
    private init() {}
    
    static func fullAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        #if DEVELOPMENT_BUILD
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
            return "\(version)-b\(build)"
        #else
            return version
        #endif
    }
    
    static func checkBetaVersion(updated: @escaping () -> Void) {
        #if DEVELOPMENT_BUILD
        let betaKey = "beta-version"
        let currentAppVersion = fullAppVersion()
        
        if UserDefaults.standard.string(forKey: betaKey) != currentAppVersion {
            UserDefaults.standard.set(currentAppVersion, forKey: betaKey)
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: updated)
        }
        #endif
    }
}
