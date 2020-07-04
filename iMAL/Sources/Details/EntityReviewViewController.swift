//
//  EntityReviewViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/01/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityReviewViewController: RootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UILabel!
    @IBOutlet var loadMoreView: UIView!
    @IBOutlet var loadMoreButton: UIButton!
    
    private var entity: TypedEntity!
    
    private var data: [Review] = []
    private var currentPage = 0
    private var shouldLoadMore = true
    
    private let reviewsPerPage = 20
    
    class func controller(withEntity entity: TypedEntity) -> EntityReviewViewController? {
        if let controller = UIStoryboard(name: "EntityDetailsMoreInfo", bundle: nil).instantiateViewController(withIdentifier: "EntityReviewViewController") as? EntityReviewViewController {
            controller.entity = entity
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reviews"
        
        tableView.isHidden = true
        loadMoreView.removeFromSuperview()
        loadNewData()
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.loadMoreButton.setTitleColor(theme.global.actionButton.color, for: .normal)
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.reloadData()
            
            self.emptyView.textColor = theme.genericView.labelText.color
        }
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        return nil
    }
    
    private func reviewAPI(page: Int) -> API {
        switch entity.kind {
        case .anime:
            return API.getAnimeReviews(anime: entity.anime!, page: page)
        case .manga:
            return API.getMangaReviews(manga: entity.manga!, page: page)
        }
    }
    
    @IBAction func loadNewData() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.tableFooterView = nil
        })
        
        if shouldLoadMore {
            reviewAPI(page: currentPage).request(loadingDelegate: self) { (success: Bool, reviews: [Review]?) in
                if success, let reviews = reviews {
                    self.data.append(contentsOf: reviews)
                    self.shouldLoadMore = reviews.count >= self.reviewsPerPage
                    self.currentPage += 1
                }
                
                self.reloadData()
            }
        }
    }
    
    private func reloadData() {
        tableView.reloadData()
        tableView.isHidden = data.isEmpty
        emptyView.isHidden = !data.isEmpty
        tableView.tableFooterView = shouldLoadMore ? loadMoreView : nil
    }
}

extension EntityReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
        
        cell.fill(with: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ReviewViewerViewController") as? ReviewViewerViewController {
            controller.review = data[indexPath.row]
            controller.entity = entity.entity
            navigationController?.pushViewController(controller, animated: true)
            delay(0.5) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
