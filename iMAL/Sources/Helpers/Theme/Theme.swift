//
//  Theme.swift
//  iMAL
//
//  Created by Jerome Ceccato on 24/04/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

class ThemeManager {
    static let themeChangedNotificationName = Notification.Name(rawValue: "imal-theme-changed")
    
    private static var storedTheme: Theme = loadDefaultTheme()
    static var currentTheme: Theme {
        get {
            return storedTheme
        }
        set {
            storedTheme = newValue
            Foundation.NotificationCenter.default.post(name: themeChangedNotificationName, object: nil)
        }
    }
    
    class func loadTheme(theme: Settings.Theme) -> Theme? {
        if let url = Bundle.main.url(forResource: "theme-\(theme.rawValue)", withExtension: "plist") {
            if let data = try? Data(contentsOf: url) {
                return try? PropertyListDecoder().decode(Theme.self, from: data)
            }
        }
        return nil
    }
    
    private class func loadDefaultTheme() -> Theme {
        return loadTheme(theme: Settings.theme) ?? loadTheme(theme: Settings.Theme.default)!
    }
    
    class func updateTheme() {
        if let newTheme = loadTheme(theme: Settings.theme) {
            currentTheme = newTheme
        }
    }
}

class Theme: Codable {
    struct MALColorCode: Codable {
        var watching: Color
        var completed: Color
        var onHold: Color
        var dropped: Color
        var planToWatch: Color
    }
    var colorCode: MALColorCode
    
    struct Bar: Codable {
        var background: OptionalColor
        var style: BarStyle
        var title: Color
        var content: Color
    }
    
    struct Toast: Codable {
        var background: Color
        var content: Color
        var activityIndicator: Color
    }
    
    struct LoadingIndicators: Codable {
        var standalone: Toast
        var regular: LoadingIndicator
    }
    
    struct Global: Codable {
        var bars: Bar
        var activeTint: Color
        
        var statusBar: StatusBarStyle

        var viewBackground: Color
        
        var scrollIndicators: ScrollIndicator
        
        var selectableCellBackground: Color
        var selectableCellHighlightedBackground: Color
        
        var genericText: Color
        var actionButton: Color
        var link: Color
        var destructiveButton: Color
        
        var keyboardStyle: KeyboardStyle
        var keyboardIndicator: Color
        
        var loadingIndicators: LoadingIndicators
    }
    var global: Global
    
    struct Picker: Codable {
        var background: OptionalColor
        var text: Color
    }
    var picker: Picker
    
    struct Header: Codable {
        var bar: Bar
        
        var closedIndicator: Color
        var tapToOpenIndicator: Color
    }
    var header: Header
    
    struct Separators: Codable {
        var entityList: OptionalColor
        var heavy: Color
        var light: Color
        var pickers: Color
    }
    var separators: Separators
    
    struct Entity: Codable {
        var name: Color
        var type: Color
        var status: Color
        var score: Color
        var metrics: Color
        var label: Color
        var tags: Color
        var incrementButton: Color
        var pictureBackground: Color
        
        var htmlDescription: Color
        var cardsInfoBackground: Color
        var cardsInfoOverlayBackground: Color
    }
    var entity: Entity
    
    struct AiringTime: Codable {
        var regular: Color
        var separator: Color
        var available: Color
        var upToDate: Color
        var notAiredYet: Color
    }
    var airingTime: AiringTime
    
    struct DropdownPopup: Codable {
        var overlay: Color
        var background: Color
        var itemsRegularBackground: Color
        var itemsSelectedBackground: Color
        var sectionText: Color
        var selectedText: Color
        var regularText: Color
        var checkmark: Color
    }
    var dropdownPopup: DropdownPopup
    
    struct ActionPopup: Codable {
        var overlay: Color
        var background: Color
        var title: Color
        var text: Color
    }
    var actionPopup: ActionPopup
    
    struct PreviewPopup: Codable {
        var blurEffect: BlurStyle
        var blurOverlay: Color
        var header: Color
        var background: Color
    }
    var previewPopup: PreviewPopup
    
    struct DetailsView: Codable {
        var sectionTitle: Color
        
        var editableLabel: Color
        var editableContent: Color
        var editableExtra: Color
        var editableRegularBackground: Color
        var editableSelectedBackground: Color
        
        var informationLabel: Color
        var informationContent: Color
        
        var relatedCategory: Color
    }
    var detailsView: DetailsView
    
    struct GenericView: Codable {
        var importantText: Color
        var importantSubtitleText: Color
        var subtitleText: Color
        var labelText: Color
        var highlightedText: Color
        var warningText: Color
        var htmlLongDescription: Color
        
        var headerBackground: Color
    }
    var genericView: GenericView
    
    struct Misc: Codable {
        var listFooterText: Color
        var comparisonPositive: Color
        var comparisonNegative: Color
    }
    var misc: Misc
    
    struct Settings: Codable {
        var backgroundColor: Color
        var cellBackgroundColor: Color
        var cellSelectedColor: Color
    }
    var settings: Settings
}
