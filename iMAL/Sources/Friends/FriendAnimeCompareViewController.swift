//
//  FriendAnimeCompareViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendAnimeCompareViewController: FriendCompareViewController {
    override var entityName: String {
        return "Anime"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CurrentUser.me.observing.observe(from: self, options: .anime) { [weak self] _ in
            self?.reloadContent()
        }
        
        CurrentUser.me.loadAnimeList(option: .neverReload, loadingDelegate: self, completion: { animelist in
            if let animelist = animelist {
                self.reloadContent(withMyList: animelist.items)
            }
        })
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    private func reloadContent() {
        if let animeList = CurrentUser.me.cachedAnimeList() {
            reloadContent(withMyList: animeList.items)
        }
    }
}
