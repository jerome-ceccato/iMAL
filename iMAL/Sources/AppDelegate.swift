//
//  AppDelegate.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import TwitterKit
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, Themeable {

    var window: UIWindow?
    
    var sentToBackground: Bool = true
    
    static var shared: AppDelegate! {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var viewPortSize: CGSize {
        return window?.bounds.size ?? UIScreen.main.bounds.size
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Analytics.setup()
        AiringNotificationsCenter.setup()
        SocialNetworkManager.setup()

        checkPreviousVersion()
        
        NetworkManagerContext.currentContext.logLevel = .simple
        
        if let credentials = CurrentUser.me.storedCredentials {
            NetworkManagerContext.currentContext.credentials = credentials
            window?.rootViewController = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()
        }
        
        initGlobalTheme()
        
        return true
    }
    
    private func initGlobalTheme() {
        applyTheme { [unowned self] theme in
            if #available(iOS 11.0, *) {
                let mainColor = theme.global.bars.title.color
                
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: mainColor]
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = mainColor
                
                UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: mainColor]
            }
            
            UIPickerView.appearance().backgroundColor = theme.picker.background.color
            UIDatePicker.appearance().backgroundColor = theme.picker.background.color
            
            UITabBar.appearance().tintColor = theme.global.activeTint.color

            self.updateToastStyle(with: theme.global.loadingIndicators.standalone)
            self.updateAppIcon(with: Settings.theme)
        }
    }
    
    private func updateToastStyle(with theme: Theme.Toast) {
        var style = ToastManager.shared.style
        
        style.backgroundColor = theme.background.color
        style.activityBackgroundColor = theme.background.color
        style.activityIndicatorColor = theme.activityIndicator.color
        style.titleColor = theme.content.color
        style.messageColor = theme.content.color
        
        style.imageSize = CGSize(width: 50, height: 50)
        style.verticalPadding = 25
        style.horizontalPadding = 25

        ToastManager.shared.style = style
    }
    
    private func updateAppIcon(with theme: Settings.Theme) {
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                UIApplication.shared.setAlternateIconName(theme.appIconFilename) { error in
                    // Cannot be nil on iOS 10.3.X
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        return DeeplinkManager.handle(url: url)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        sentToBackground = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Analytics.appDidOpen()
        Communication.updateIfNeeded()
        
        if sentToBackground {
            sentToBackground = false
            Database.shared.updateAiringAnimeDataIfNeeded()
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch Settings.orientationPreference {
        case .device:
            return .all
        case .portait:
            return .portrait
        case .landscape:
            return .landscape
        }
    }
    
    private func checkPreviousVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(version, forKey: "version")
            UserDefaults.standard.synchronize()
        }
        
        #if DEVELOPMENT_BUILD
            BetaUtils.checkBetaVersion(updated: {
                if let controller = self.window?.rootViewController {
                    BetaInformationsViewController.present(in: controller)
                }
            })
        #endif
    }
    
    class func controllerForModalPresentation() -> UIViewController? {
        if var controller = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController {
            while controller.presentedViewController != nil {
                controller = controller.presentedViewController!
            }
            return controller
        }
        return nil
    }
}
