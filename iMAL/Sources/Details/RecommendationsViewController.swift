//
//  RecommendationsViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/02/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class RecommendationsViewController: RootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UILabel!
    
    private var entity: TypedEntity!
    private var data: [Recommendation] = []
    
    class func controller(withEntity entity: TypedEntity) -> RecommendationsViewController? {
        if let controller = UIStoryboard(name: "EntityDetailsMoreInfo", bundle: nil).instantiateViewController(withIdentifier: "RecommendationsViewController") as? RecommendationsViewController {
            controller.entity = entity
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recommendations"
        
        tableView.isHidden = true
        loadData()
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.reloadData()
            
            self.emptyView.textColor = theme.genericView.labelText.color
        }
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        return nil
    }
    
    private func recommendationAPI() -> API {
        switch entity.kind {
        case .anime:
            return API.getAnimeRecommendations(anime: entity.anime!)
        case .manga:
            return API.getMangaRecommendations(manga: entity.manga!)
        }
    }
    
    @IBAction func loadData() {
        recommendationAPI().request(loadingDelegate: self) { (success: Bool, recommendations: [Recommendation]?) in
            if success, let recommendations = recommendations {
                self.data = recommendations
            }
            
            self.reloadData()
        }
    }
    
    private func reloadData() {
        tableView.reloadData()
        tableView.isHidden = data.isEmpty
        emptyView.isHidden = !data.isEmpty
    }
}

extension RecommendationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationTableViewCell", for: indexPath) as! RecommendationTableViewCell
        
        cell.fill(with: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = RecommendationsDetailsViewController.controller(withRecommendation: data[indexPath.row]) {
            navigationController?.pushViewController(controller, animated: true)
        }
        delay(0.5) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
