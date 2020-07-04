//
//  ErrorCenter.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 25/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class ErrorCenter {
    private static var bugReportAction: ErrorCenter.Action = {
        ErrorCenter.Action(name: "Report a bug", callback: { context in
            if Communication.unreadMessages == 0 {
                EmailSender.sendEmail(from: context.controller, title: "[iMAL][Bug report]", content: EmailSender.bugReportContent(context: context.toString()), completion: context.completion)
            }
            else {
                let message = ErrorCenter.Message(title: "Unread messages", body: "You have unread system messages. You can read them by tapping the \"Settings\" tab and then \"View all news\". News may contain explanations for known bugs, please read them and make sure your issue has not already been addressed.", cancelAction: Action(name: "OK"))
                ErrorCenter.present(error: message, from: context.controller, context: context)
            }
        })
    }()
    
    private static var retryAction: ErrorCenter.Action = {
        ErrorCenter.Action(name: "Retry", callback: { context in
            context.networkOperation?.retry()
        })
    }()
    
    private static var loginAction: ErrorCenter.Action = {
        ErrorCenter.Action(name: "Login", callback: { _ in
            if let homeController = CustomTabBarController.shared {
                homeController.dismissPresentedControllersIfNeeded {
                    if let loginController = LoginViewController.controllerWithCurrentRootController(homeController) {
                        homeController.present(loginController, animated: true)
                    }
                }
            }
        })
    }()
    
    private static var captchaAction: ErrorCenter.Action = {
        ErrorCenter.Action(name: "Login", callback: { context in
            API.loginURL.open(in: context.controller)
        })
    }()

    private static var defaultCompletion: (ErrorCenter.Context) -> Void = { context in
        context.completion?()
    }
    
    static var loginError: ErrorCenter.Message = {
        ErrorCenter.Message(title: "Invalid credentials",
                            body: "Your username or password is incorrect. Make sure your account has been activated by confirming your email address.",
                            cancelAction: Action(name: "OK"))
    }()
    
    static var internalServerError: ErrorCenter.Message = {
        ErrorCenter.Message(title: "Error",
                            body: "An unexpected server error occured.",
                            cancelAction: Action(name: "Close"),
                            otherActions: [ErrorCenter.bugReportAction])
    }()
    
    static func networkError(error: NSError) -> ErrorCenter.Message {
        return ErrorCenter.Message(title: "Network Error",
                                   body: error.localizedDescription,
                                   cancelAction: Action(name: "Close"),
                                   otherActions: [ErrorCenter.retryAction])
    }
    
    static func unknownServerError(error: NSError) -> ErrorCenter.Message {
        var otherActions: [Action] = [ErrorCenter.bugReportAction]
        var message = error.localizedDescription

        if message.lowercased().contains("not been approved") {
            otherActions = []
        }
        else if message.lowercased().contains("too many failed login attempts") {
            message = "You have been temporarily banned from MAL. Please wait at least 2 hours before trying again.\nOriginal error: \(message)"
            otherActions = []
        }
        else if message.lowercased().contains("invalid credentials") {
            message = "Your username or password is invalid. Please login again.\nOriginal error: \(message)"
            otherActions = [ErrorCenter.loginAction]
        }
        else if message.lowercased().contains("website login required") {
            message = "MAL is asking you to solve a captcha to be able to access the app. Please login using the website and try again.\nOriginal error: \(message)"
            otherActions = [ErrorCenter.captchaAction]
        }
        else if message.lowercased().contains("is already in the list") {
            let entityName = message.lowercased().contains("manga") ? "manga" : "anime"
            message = "This \(entityName) is already in your list. Please reload your list and try again.\nOriginal error: \(message)"
            otherActions = []
        }
        
        return ErrorCenter.Message(title: "Error",
                                   body: message,
                                   cancelAction: Action(name: "Close"),
                                   otherActions: otherActions)
    }
    
    static var noEntityDetailsError: ErrorCenter.Message = {
        ErrorCenter.Message(title: "Error",
                            body: "Unable to load additional info for this anime/manga. Please report this issue.",
                            cancelAction: Action(name: "Close"),
                            otherActions: [ErrorCenter.bugReportAction])
    }()
    
    static var unableToVerifyCredentials: ErrorCenter.Message = {
        ErrorCenter.Message(title: "Unable to verify credentials",
                            body: "Please check your internet connection and try again.",
                            cancelAction: Action(name: "Close"))
    }()
}

extension ErrorCenter {
    class Message {
        var title: String
        var body: String
        var otherActions: [Action]
        var cancelAction: Action
        
        init(title: String, body: String, cancelAction: Action, otherActions: [Action] = []) {
            self.title = title
            self.body = body
            self.otherActions = otherActions
            self.cancelAction = cancelAction
        }
    }
    
    class Action {
        var name: String
        var callback: (ErrorCenter.Context) -> Void
        
        init(name: String, callback: ((ErrorCenter.Context) -> Void)? = nil) {
            self.name = name
            self.callback = callback ?? ErrorCenter.defaultCompletion
        }
    }
    
    class Context {
        var controller: UIViewController
        var networkOperation: NetworkRequestOperation?
        var completion: (() -> Void)?
        var error: NSError?
        var rawContext: String?
        
        init(controller: UIViewController, error: NSError?, rawContext: String? = nil, networkOperation: NetworkRequestOperation? = nil, completion: (() -> Void)? = nil) {
            self.controller = controller
            self.error = error
            self.rawContext = rawContext
            self.networkOperation = networkOperation
            self.completion = completion
        }
        
        func toString() -> String? {
            if let rawContext = rawContext {
                return rawContext
            }
            return "\n\(type(of: controller))\n" + (error != nil ? "\(error!.code) (\(error!.localizedDescription))\n" : "") + (networkOperation?.resource != nil ? "\(networkOperation!.resource!)" : "")
        }
    }
}

extension ErrorCenter {
    class func present(error: ErrorCenter.Message, from controller: UIViewController, context: ErrorCenter.Context) {
        let alert = UIAlertController(title: error.title, message: error.body, preferredStyle: .alert)

        error.otherActions.forEach { action in
            alert.addAction(UIAlertAction(title: action.name, style: .default, handler: { _ in action.callback(context) }))
        }
        alert.addAction(UIAlertAction(title: error.cancelAction.name, style: .cancel, handler: { _ in error.cancelAction.callback(context) }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        switch error.code {
        case 500 ..< 600:
            return ErrorCenter.internalServerError
        case 200 ..< 400:
            return nil
        case NSURLErrorCancelled:
            return nil
        case NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorDNSLookupFailed,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorSecureConnectionFailed,
             NSURLErrorServerCertificateUntrusted,
             NSURLErrorCallIsActive:
            return ErrorCenter.networkError(error: error)
        default:
            return ErrorCenter.unknownServerError(error: error)
        }
    }
}

extension ErrorCenter {
    class func sendBugReport(from: UIViewController, context: String?, completion: (() -> Void)? = nil) {
        let error = ErrorCenter.Context(controller: from, error: nil, rawContext: context ?? "", completion: completion)
        ErrorCenter.bugReportAction.callback(error)
    }
}
