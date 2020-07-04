//
//  DropdownNavigationController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 01/11/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class DropdownNavigationController: UINavigationController {
    static func containedController(from controller: UIViewController) -> DropdownContainedControllerProtocol! {
        return (controller as? DropdownNavigationController)?.containedController()
    }
    
    func containedController() -> DropdownContainedControllerProtocol! {
        return viewControllers.first as? DropdownContainedControllerProtocol
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFakeNavBar()
    }
    
    private func setupFakeNavBar() {
        navigationBar.barTintColor = UIColor.clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.barPressed)))
    }
    
    @IBAction func barPressed() {
        (viewControllers.first as? DropdownContainedControllerProtocol)?.closePressed()
    }
}
