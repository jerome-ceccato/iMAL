//
//  FriendMangaCompareViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendMangaCompareViewController: FriendCompareViewController {
    override var entityName: String {
        return "Manga"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.me.observing.observe(from: self, options: .manga) { [weak self] _ in
            self?.reloadContent()
        }

        CurrentUser.me.loadMangaList(option: .neverReload, loadingDelegate: self, completion: { mangalist in
            if let mangalist = mangalist {
                self.reloadContent(withMyList: mangalist.items)
            }
        })
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    private func reloadContent() {
        if let mangaList = CurrentUser.me.cachedMangaList() {
            reloadContent(withMyList: mangaList.items)
        }
    }
}
