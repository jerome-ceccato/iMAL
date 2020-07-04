//
//  Themeable.swift
//  iMAL
//
//  Created by Jerome Ceccato on 24/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import Foundation

protocol Themeable: class {
    
}

extension Themeable {
    func applyTheme(handler: @escaping (Theme) -> Void) {
        handler(ThemeManager.currentTheme)
        _themeHandler.handlers.append(handler)
    }
    
    fileprivate var _themeHandler: ThemeHandler {
        if let handler = objc_getAssociatedObject(self, &themeHandlerKey) as? ThemeHandler {
            return handler
        }
        else {
            let handler = ThemeHandler()
            handler.observe()
            objc_setAssociatedObject(self, &themeHandlerKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return handler
        }
    }
}

fileprivate var themeHandlerKey = "_themeHandler"

fileprivate class ThemeHandler {
    var handlers: [(Theme) -> Void] = []
    var observer: NSObjectProtocol?
    
    func observe() {
        if let observer = observer {
            Foundation.NotificationCenter.default.removeObserver(observer)
        }
        
        observer = Foundation.NotificationCenter.default.addObserver(
            forName: ThemeManager.themeChangedNotificationName,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] _ in
                self?.handle()
        })
    }
    
    func handle() {
        handlers.forEach { handler in
            handler(ThemeManager.currentTheme)
        }
    }
    
    deinit {
        if let observer = observer {
            Foundation.NotificationCenter.default.removeObserver(observer)
        }
    }
}
