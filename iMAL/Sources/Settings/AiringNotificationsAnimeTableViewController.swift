//
//  AiringNotificationsAnimeTableViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class AiringNotificationsAnimeTableViewController: SettingsBaseTableViewController {
    private var items: [UserAnime] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Anime Filter"
        
        if Database.shared.airingAnime != nil {
            refreshContent()
        }
        Database.shared.handleAnimeAiringDataAvailableNotification(self) { [weak self] in
            self?.refreshContent()
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.backgroundColor = theme.global.viewBackground.color
        }
    }
    
    deinit {
        NotificationCenter.unregister(self)
    }
    
    private func refreshContent() {
        CurrentUser.me.loadAnimeList(option: .reloadIfCached, loadingDelegate: self) { animeList in
            if let animelist = animeList, let airingData = Database.shared.airingAnime {
                self.items = self.getAiringAnimeInMyList(animelist: animelist, airingData: airingData)
                Settings.cleanupAiringNotificationsDisabledAnimeTable(with: animelist)
                self.tableView.reloadData()
            }
        }
    }
    
    private func getAiringAnimeInMyList(animelist: AnimeList, airingData: AiringData) -> [UserAnime] {
        return airingData.anime.compactMap { animelist.find(by: $0.identifier) }
    }

    // MARK: - Tableview delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AiringNotificationsAnimeTableViewCell", for: indexPath) as! AiringNotificationsAnimeTableViewCell

        let anime = items[indexPath.row]
        cell.fill(with: anime, enabled: Settings.airingNotificationsIsAnimeEnabled(identifier: anime.animeSeries.identifier))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let anime = items[indexPath.row]
        let enabled = Settings.airingNotificationsIsAnimeEnabled(identifier: anime.animeSeries.identifier)
        Settings.airingNotificationsDisableAnime(identifier: anime.animeSeries.identifier, enabled: !enabled)
        
        AiringNotificationsCenter.shared.toggleNotifications(for: anime, enabled: !enabled)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AiringNotificationsAnimeTableViewController: NetworkLoadingController {
    var loaderContainerView: UIView { return view }
    
    func showLoaderView(_ show: Bool) {
        if show {
            loaderContainerView.makeToastActivity(.center)
        }
        else {
            loaderContainerView.hideToastActivity()
        }
    }
    
    func startLoading(_ operation: NetworkRequestOperation) {
        showLoaderView(true)
    }
    
    func stopLoading(_ operation: NetworkRequestOperation) {
        showLoaderView(false)
    }
    
    func stopLoading(_ operation: NetworkRequestOperation, withError error: NSError, completion: @escaping () -> Void) {
        stopLoading(operation)
        completion()
    }
}
