//
//  FriendMangaListViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendMangaListViewController: MangaListViewController {
    var friend: Friend!
    
    override var analyticsIdentifier: Analytics.View? {
        return .friendMangaList
    }
    
    override var cellType: EntityListCellType {
        return .friendManga
    }
    
    override var listUsername: String {
        return friend.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(friend.name)'s Manga List"
        
        CurrentUser.me.observing.observe(from: self, options: .manga) { [weak self] _ in
            self?.listDisplayProxy?.reloadData()
        }
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    override func emptyListReceived() {
        let message = ErrorCenter.Message(title: "Warning", body: "Empty list received, make sure your friend's username is correct.", cancelAction: ErrorCenter.Action(name: "OK"))
        ErrorCenter.present(error: message, from: self, context: ErrorCenter.Context(controller: self, error: nil, networkOperation: nil))
    }
    
    func myInfos(for manga: UserManga) -> UserManga? {
        return CurrentUser.me.cachedMangaList()?.find(by: manga.series.identifier)
    }
    
    override func fill(cell: EntityCell, withEntity entity: UserEntity) {
        if let cell = cell as? FriendMangaTableViewCell, let manga = entity as? UserManga {
            cell.fill(with: myInfos(for: manga))
        }
        
        super.fill(cell: cell, withEntity: entity)
    }
    
    override func animateSortButtonChanges(appear: Bool, context: AnyObject? = nil) {
        animateNavigationBarUpdate(duration: 0.1) {
            if appear {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Apply", style: .plain, target: nil, action: nil)
            }
            else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
}

// MARK: - Actions
extension FriendMangaListViewController {
    @IBAction func comparePressed() {
        guard !items.isEmpty else {
            return
        }
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "FriendMangaCompareViewController") as? FriendMangaCompareViewController {
            controller.friend = friend
            controller.friendList = items
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
