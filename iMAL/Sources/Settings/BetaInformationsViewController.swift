//
//  BetaInformationsViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/04/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BetaInformationsViewController: RootViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var changelogLabel: UILabel!
    
    @IBOutlet var regularLabels: [UILabel]!
    @IBOutlet var closeButton: UIButton!

    class func present(in controller: UIViewController) {
        #if DEVELOPMENT_BUILD
        if let this = UIStoryboard(name: "Beta", bundle: nil).instantiateInitialViewController() {
            controller.present(this, animated: true, completion: nil)
        }
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iMAL \(BetaUtils.fullAppVersion())"
        
        if let path = Bundle.main.path(forResource: "changelog", ofType: nil), let content = try? String(contentsOfFile: path) {
            changelogLabel.text = content
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.scrollView.indicatorStyle = theme.global.scrollIndicators.style
            self.regularLabels.forEach { label in
                label.textColor = theme.genericView.importantText.color
            }
            self.closeButton.backgroundColor = theme.global.actionButton.color
        }
        
        scrollView.flashScrollIndicators()
    }
    
    @IBAction func dismissPressed() {
        dismiss(animated: true, completion: nil)
    }
}
