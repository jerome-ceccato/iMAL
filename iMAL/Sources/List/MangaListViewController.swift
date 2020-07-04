//
//  MangaListViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaListViewController: EntityListViewController {
    override var cellType: EntityListCellType {
        return editable ? .editableManga : .manga
    }

    override var currentSortingStatus: EntityListSorting {
        didSet {
            if editable {
                Settings.mangaListSortingOptions = currentSortingStatus
            }
        }
    }
    
    var listUsername: String {
        return NetworkManagerContext.currentContext.credentials?.username ?? ""
    }
    
    override func viewDidLoad() {
        currentSortingStatus = Settings.mangaListSortingOptions
        previousSortingStatus = currentSortingStatus
        
        super.viewDidLoad()
    }
    
    override func remoteReloadList(_ completion: @escaping () -> Void) {
        let username = listUsername
        
        API.getMangaList(username: username).request(loadingDelegate: self) { (success: Bool, mangalist: MangaList?) in
            if let mangalist = mangalist, success {
                if mangalist.items.isEmpty {
                    self.emptyListReceived()
                }
                self.setMangaListAndReloadContent(mangalist)
            }
            completion()
        }
    }

    func setMangaListAndReloadContent(_ mangalist: MangaList) {
        items = mangalist.items
        reloadContent()
    }
    
    override func sectionPressed(_ section: Int) {
        super.sectionPressed(section)
        
        if editable && currentSortingStatus.grouping == .status {
            Settings.mangaStatusSectionState = currentSectionsExpandedState()
        }
    }
    
    override func storedStatusSectionState(for section: String) -> Bool? {
        return Settings.mangaStatusSectionState[UserManga.Status.statusForDisplayString(section)]
    }
    
    override func footerContentString() -> String {
        var entries = 0, volumes = 0, chapters = 0
        (items as? [UserManga])?.forEach { item in
            entries += item.readChapters > 0 || item.readVolumes > 0 ? 1 : 0
            chapters += item.readChapters
            volumes += item.readVolumes
        }
        
        return "Read \(entries) manga, \(volumes) volume\(volumes > 1 ? "s" : ""), \(chapters) chapter\(chapters > 1 ? "s" : "")"
    }
}
