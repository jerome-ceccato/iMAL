//
//  AnimeListViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimeListViewController: EntityListViewController {
    private(set) var animelist: AnimeList? = nil
    
    override var cellType: EntityListCellType {
        return editable ? .editableAnime : .anime
    }
    
    override var currentSortingStatus: EntityListSorting {
        didSet {
            if editable {
                Settings.animeListSortingOptions = currentSortingStatus
            }
        }
    }
    
    var listUsername: String {
        return NetworkManagerContext.currentContext.credentials?.username ?? ""
    }
    
    override func viewDidLoad() {
        currentSortingStatus = Settings.animeListSortingOptions
        previousSortingStatus = currentSortingStatus
        
        super.viewDidLoad()
        
        Database.shared.handleAnimeAiringDataAvailableNotification(self) { [weak self] in
            self?.reloadContent()
        }
    }
    
    override func remoteReloadList(_ completion: @escaping () -> Void) {
        let username = listUsername
        
        API.getAnimeList(username: username).request(loadingDelegate: self) { (success: Bool, animelist: AnimeList?) in
            if let animelist = animelist, success {
                if animelist.items.isEmpty {
                    self.emptyListReceived()
                }
                self.setAnimeListAndReloadContent(animelist)
            }
            completion()
        }
    }
    
    func setAnimeListAndReloadContent(_ animelist: AnimeList) {
        self.animelist = animelist
        
        items = animelist.items
        reloadContent()
    }
    
    override func sectionPressed(_ section: Int) {
        super.sectionPressed(section)
        
        if editable && currentSortingStatus.grouping == .status {
            Settings.animeStatusSectionState = currentSectionsExpandedState()
        }
    }
    
    override func storedStatusSectionState(for section: String) -> Bool? {
        return Settings.animeStatusSectionState[UserAnime.Status.statusForDisplayString(section)]
    }
    
    override func footerContentString() -> String {
        var entries = 0, episodes = 0
        (items as? [UserAnime])?.forEach { item in
            entries += item.watchedEpisodes > 0 ? 1 : 0
            episodes += item.watchedEpisodes
        }
        
        var content = "Watched \(entries) anime, \(episodes) episode\(episodes > 1 ? "s" : "")"
        
        if let daysWatched = animelist?.daysWatched {
            content += ", \(String(format: "%.2f", daysWatched)) day\(daysWatched > 1 ? "s" : "")"
        }
        return content
    }
}
