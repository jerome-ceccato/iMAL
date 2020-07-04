//
//  LoginViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class LoginViewController: RootViewController {
    @IBOutlet var fieldsContainerView: UIView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var socialButton: UIButton!
    
    @IBOutlet var keyboardHeightConstraint: NSLayoutConstraint!
    
    private var alreadyLoggedIn: Bool = false
    private var loggedOut: Bool = false
    private var currentHomeController: CustomTabBarController?
    
    override var analyticsIdentifier: Analytics.View? {
        return .login
    }
    
    class func controllerWithCurrentRootController(_ home: CustomTabBarController, alreadyLoggedIn: Bool = true, loggedOut: Bool = false) -> UINavigationController? {
        if let nav = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            if let controller = nav.viewControllers.first as? LoginViewController {
                
                controller.alreadyLoggedIn = alreadyLoggedIn
                controller.loggedOut = loggedOut
                controller.currentHomeController = home
                return nav
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = alreadyLoggedIn ? "Switch account" : "Authentication"
        initialLayout()
        
        if loggedOut {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.view.makeToast("Invalid credentials. Please login again.")
            }
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.settings.backgroundColor.color
            self.fieldsContainerView.backgroundColor = theme.settings.cellBackgroundColor.color
            [self.usernameLabel, self.passwordLabel].forEach { label in
                label?.textColor = theme.genericView.importantText.color
            }
            [self.usernameField, self.passwordField].forEach { textField in
                textField?.textColor = theme.genericView.importantText.color
                textField?.tintColor = theme.global.keyboardIndicator.color
                textField?.keyboardAppearance = theme.global.keyboardStyle.style
            }
            self.signInButton.backgroundColor = theme.global.actionButton.color
            [self.socialButton, self.registerButton].forEach { button in
                button?.setTitleColor(theme.global.actionButton.color, for: .normal)
            }
            self.navigationItem.leftBarButtonItem?.tintColor = theme.global.bars.content.color
        }
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        if error.code == 401 {
            return ErrorCenter.loginError
        }
        return super.messageForNetworkError(error)
    }
}

// MARK: - Layout
private extension LoginViewController {
    func initialLayout() {
        socialButton.titleLabel?.lineBreakMode = .byWordWrapping
        socialButton.titleLabel?.textAlignment = .center
        
        signInButton.layer.cornerRadius = 3
        signInButton.layer.masksToBounds = true
        
        usernameField.text = CurrentUser.me.currentUsername
        
        if #available(iOS 11.0, *) {
            usernameField.textContentType = .username
            passwordField.textContentType = .password
        }
        
        if alreadyLoggedIn {
            registerButton.isHidden = true
            socialButton.isHidden = true
        }
        else {
            navigationItem.leftBarButtonItem = nil
        }
    }
}

// MARK: - Actions
extension LoginViewController {
    @IBAction func signInPressed() {
        if usernameField.textString.isEmpty {
            usernameField.becomeFirstResponder()
        }
        else if passwordField.textString.isEmpty {
            passwordField.becomeFirstResponder()
        }
        else {
            NetworkManagerContext.currentContext.credentials = NetworkManagerContext.Credentials(username: usernameField.textString, password: passwordField.textString)
            
            title = "Signing in..."
            API.verifyCredentials.request(loadingDelegate: self) { success in
                if success {
                    self.title = "Signed in"
                    CurrentUser.me.storedCredentials = NetworkManagerContext.currentContext.credentials
                    self.dismissKeyboard()
                    self.showHomeController()
                }
                else {
                    self.title = self.alreadyLoggedIn ? "Switch account" : "Authentication"
                    NetworkManagerContext.currentContext.credentials = CurrentUser.me.storedCredentials
                }
            }
        }
    }
    
    @IBAction func registerPressed() {
        API.registrationURL?.open(in: self)
    }
    
    @IBAction func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func socialPressed() {
       let alert = UIAlertController(title: "Social account", message: "iMAL currently does not support login through social networks.\nYou need to set a password for your account in order to use iMAL.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Set password", style: .default, handler: { _ in
            API.editPasswordURL?.open(in: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showHomeController() {
        if let homeController = currentHomeController, alreadyLoggedIn || loggedOut {
            homeController.setupControllers()
            CurrentUser.me.clearUserLists()
            AiringNotificationsCenter.shared.refreshScheduledNotificationsIfNeeded()
            homeController.dismiss(animated: true, completion: nil)
        }
        else if let controller = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - TextField
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            usernameField.resignFirstResponder()
            view.setNeedsLayout()
            view.layoutIfNeeded()
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            signInPressed()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
}

// MARK: - KeyboardDelegate
extension LoginViewController: KeyboardDelegate {
    func animateAlongSideKeyboardAnimation(appear: Bool, height: CGFloat) {
        keyboardHeightConstraint.constant = 20 + height
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unconfigureKeyboard()
    }
}
