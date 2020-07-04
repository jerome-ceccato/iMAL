//
//  ReviewViewerViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/01/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class ReviewViewerViewController: RootViewController {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var helpfulLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var webView: UIWebView!
    
    var review: Review!
    var entity: Entity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = entity.name

        loadStaticContent()
        
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        webView.scrollView.indicatorStyle = .white
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.headerView.backgroundColor = theme.genericView.headerBackground.color
            
            self.avatarImageView.backgroundColor = theme.entity.pictureBackground.color
            self.usernameLabel.textColor = theme.genericView.importantText.color
            self.ratingLabel.textColor = theme.genericView.highlightedText.color
            self.subtitleLabel.textColor = theme.genericView.subtitleText.color
            
            self.webView.scrollView.indicatorStyle = theme.global.scrollIndicators.style

            self.reloadDynamicContent()
        }
    }
    
    func loadStaticContent() {
        avatarImageView.image = nil
        if let url = review.avatarURL {
            avatarImageView.setImageWithURLString(url)
        }
        
        usernameLabel.text = review.username
        ratingLabel.text = "\(review.rating)"
        
        let secondaryInfos = [review.date?.shortDateDisplayString, review.mainMetricDisplayString].compactMap({ ($0?.isEmpty ?? true) ? nil : $0 })
        subtitleLabel.text = secondaryInfos.joined(separator: " | ")
    }
    
    func reloadDynamicContent() {
        let theme = ThemeManager.currentTheme.genericView
        let helpfulContent = NSMutableAttributedString(string: "\(review.helpfulCount)", attributes: [NSAttributedStringKey.foregroundColor: theme.importantText.color])
        helpfulContent.append(NSAttributedString(string: " people found helpful", attributes: [NSAttributedStringKey.foregroundColor: theme.labelText.color]))
        helpfulLabel.attributedText = helpfulContent
        
        let content = EntityHTMLRepresentation.htmlTemplate(withContent: "<br/>\(review.review)<br/><br/>", fontSize: 17, color: theme.htmlLongDescription.color)
        webView.loadHTMLString(content, baseURL: nil)
    }
}
