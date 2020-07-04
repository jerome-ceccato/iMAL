//
//  AnimeEpisodesViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 29/01/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class AnimeEpisodesViewController: RootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UILabel!
    @IBOutlet var loadMoreView: UIView!
    @IBOutlet var loadMoreButton: UIButton!
    
    private var anime: Anime!
    
    private var data: [Episode] = []
    private var currentPage = 0
    private var shouldLoadMore = true
    
    private let episodesPerPage = 100
    
    class func controller(withAnime anime: Anime) -> AnimeEpisodesViewController? {
        if let controller = UIStoryboard(name: "AnimeDetailsMoreInfo", bundle: nil).instantiateViewController(withIdentifier: "AnimeEpisodesViewController") as? AnimeEpisodesViewController {
            controller.anime = anime
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episodes"
        
        tableView.isHidden = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        
        loadMoreView.removeFromSuperview()
        loadNewData()
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.loadMoreButton.setTitleColor(theme.global.actionButton.color, for: .normal)
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.reloadData()
            
            self.emptyView.textColor = theme.genericView.labelText.color
        }
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        return nil
    }
    
    @IBAction func loadNewData() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.tableFooterView = nil
        })
        
        if shouldLoadMore {
            API.getEpisodes(anime: anime, page: currentPage).request(loadingDelegate: self) { (success: Bool, episodes: [Episode]?) in
                if success, let episodes = episodes {
                    self.data.append(contentsOf: episodes)
                    self.shouldLoadMore = episodes.count >= self.episodesPerPage
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

extension AnimeEpisodesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeEpisodeTableViewCell", for: indexPath) as! AnimeEpisodeTableViewCell
        
        cell.fill(with: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
