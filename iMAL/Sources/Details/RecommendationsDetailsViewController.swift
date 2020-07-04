//
//  RecommendationsDetailsViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 02/02/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class RecommendationsDetailsViewController: RootViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var openButtonLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    private var data: Recommendation!
    
    class func controller(withRecommendation recommendation: Recommendation) -> RecommendationsDetailsViewController? {
        if let controller = UIStoryboard(name: "EntityDetailsMoreInfo", bundle: nil).instantiateViewController(withIdentifier: "RecommendationsDetailsViewController") as? RecommendationsDetailsViewController {
            controller.data = recommendation
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = data.entity.entity.name
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        pictureImageView.setImageWithURLString(data.entity.entity.pictureURL)
        titleLabel.text = data.entity.entity.name
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.headerView.backgroundColor = theme.genericView.headerBackground.color
            
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.titleLabel.textColor = theme.genericView.importantText.color
            self.openButtonLabel.textColor = theme.global.actionButton.color

            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.reloadData()
        }
    }
    
    @IBAction func headerPressed() {
        if let controller = EntityDetailsViewController.controller(for: data.entity.entity) {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension RecommendationsDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.recommendations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationContentTableViewCell", for: indexPath) as! RecommendationContentTableViewCell
        
        cell.fill(with: data.recommendations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
