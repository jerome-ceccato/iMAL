//
//  EmailSender.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 25/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit
import MessageUI

class EmailSender: NSObject {
    private static let instance = EmailSender()
    private var parentController: UIViewController?
    
    class func sendEmail(from controller: UIViewController, title: String, content: String, completion: (() -> Void)?) {
        instance.parentController = controller
        instance.sendEmail(title: title, content: content, completion: completion)
    }
}

// MARK: - Messages
extension EmailSender {
    class func bugReportContent(context: String? = nil) -> String {
        var content = "[write a description of the bug here]\n\n\n----\n"
        
        content += "iMAL version: \(BetaUtils.fullAppVersion())\n"
        content += "Device model: \(UIDevice.current.platformDisplayString())\n"
        content += "iOS version: \(UIDevice.current.systemVersion)\n"
        content += "MAL username: \(CurrentUser.me.currentUsername)\n"
        if let context = context {
            content += "Context: \(context)\n"
        }
        return content
    }
    
    class func regularMailContent() -> String {
        var content = "\n\n\n----\n"
        
        content += "iMAL version: \(BetaUtils.fullAppVersion())\n"
        content += "Device model: \(UIDevice.current.platformDisplayString())\n"
        content += "iOS version: \(UIDevice.current.systemVersion)\n"
        content += "MAL username: \(CurrentUser.me.currentUsername)\n"
        return content
    }
}

extension EmailSender: MFMailComposeViewControllerDelegate {
    func sendEmail(title: String, content: String, completion: (() -> Void)?) {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            
            controller.mailComposeDelegate = self
            controller.setToRecipients([Global.contactEmailAddress])
            #if DEVELOPMENT_BUILD
                controller.setSubject(title + "[Beta \(BetaUtils.fullAppVersion())]")
            #else
                controller.setSubject(title)
            #endif
            controller.setMessageBody(content, isHTML: false)
            
            parentController?.present(controller, animated: true, completion: completion)
        }
        else {
            alert(nil, message: "Your device can't send email or you don't have any email address associated with it.", presentationCompletion: completion)
        }
    }
    
    private func alert(_ title: String?, message: String, presentationCompletion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        parentController?.present(alert, animated: true, completion: presentationCompletion)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                self.alert(nil, message: "Thank you!")
            case .failed:
                self.alert("Error", message: "An unknown error has occured, your email has not been sent. Please try again.")
            default:
                break
            }
            self.parentController = nil
        }
    }
}
