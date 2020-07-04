//
//  HomeAnimeListViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class HomeAnimeListViewController: AnimeListViewController {
    override var analyticsIdentifier: Analytics.View? {
        return .userAnimeList
    }
    
    override var listStyle: ListDisplayStyle {
        return Settings.listsStyle
    }
    
    override func viewDidLoad() {
        refreshSynchronizationStatus()
        
        super.viewDidLoad()
        buildSearchController()
        
        CurrentUser.me.observing.observe(from: self, options: [.anime, .animeRefresh]) { [weak self] content in
            switch content {
            case .animeAdd, .animeDelete:
                self?.forceUpdateListFromStoredList(newData: true)
            case .animeUpdate:
                self?.forceUpdateListFromStoredList(newData: false)
            case .animeListWillRefresh:
                self?.willSynchronizeList()
            case .animeListDidRefresh(let new):
                self?.reSynchronizeList(animelist: new)
            default:
                break
            }
        }
        
        Settings.handleAnimeExpandOptionsUpdatedNotification(self) { [weak self] in
            self?.setCurrentSectionsExpandedState(Settings.animeStatusSectionState)
        }
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    override var editable: Bool {
        return true
    }
    
    func refreshSynchronizationStatus(status: String? = nil) {
        if let status = status {
            navigationItem.title = status
        }
        else {
            let cachedTitle = !CurrentUser.me.animeList.synchronized && !items.isEmpty
            navigationItem.title = cachedTitle ? "Cached Anime List" : "My Anime List"
        }
    }
    
    override func fill(cell: EntityCell, withEntity entity: UserEntity) {
        if let editableCell = cell as? EditableAnimeCell {
            editableCell.delegate = self
        }
        
        super.fill(cell: cell, withEntity: entity)
    }
    
    func didReceiveNewList(animelist: AnimeList?) {
        self.shouldReloadAfterEditEnds = false
        if let animelist = animelist {
            if animelist.items.isEmpty {
                self.emptyListReceived()
            }
            self.setAnimeListAndReloadContent(animelist)
        }
        refreshSynchronizationStatus()
    }
    
    override func remoteReloadList(_ completion: @escaping () -> Void) {
        CurrentUser.me.loadAnimeList(option: .alwaysReload, loadingDelegate: self) { animelist in
            self.didReceiveNewList(animelist: animelist)
            completion()
        }
    }
    
    override func loadCachedList() -> Bool {
        if let list = CurrentUser.me.cachedAnimeList() {
            setAnimeListAndReloadContent(list)
            
            if !CurrentUser.me.animeList.synchronized {
                willSynchronizeList(canReload: false)
                CurrentUser.me.loadAnimeList(option: .reloadIfCached, loadingDelegate: nil, completion: { animelist in
                    self.reSynchronizeList(animelist: animelist)
                })
            }
            return true
        }
        return false
    }
    
    func willSynchronizeList(canReload: Bool = true) {
        refreshSynchronizationStatus(status: "Synchronizing...")
        if !editingLocked && !items.isEmpty {
            reloadContent()
        }
    }
    
    func reSynchronizeList(animelist: AnimeList?) {
        if editingLocked {
            shouldReloadAfterEditEnds = true
        }
        else {
            didReceiveNewList(animelist: animelist)
        }
    }
    
    override var areCellsGloballyLocked: Bool {
        return !CurrentUser.me.animeList.editable
    }
    
    override func setAnimeListAndReloadContent(_ animelist: AnimeList) {
        super.setAnimeListAndReloadContent(animelist)
        delay(0.1) {
            DeeplinkManager.triggerPendingLink(context: self)
        }
    }
}

extension HomeAnimeListViewController: EditableAnimeActionDelegate {
    func animeDidUpdate(_ changes: AnimeChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void) {
        updateAnime(with: changes, loadingDelegate: loadingDelegate ?? self, completion: completion)
    }
    
    private func updateAnime(with changes: AnimeChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void) {
        if changes.hasChanges() {
            API.updateAnime(changes: changes).request(loadingDelegate: loadingDelegate) { success in
                completion()
                if success {
                    loadingDelegate?.view.makeSuccessToast {
                        SocialNetworkManager.postChanges(changes, fromViewController: self)
                        changes.commitChanges()
                        
                        CurrentUser.me.observing.disablingObservation(for: self) {
                            CurrentUser.me.updateAnime(changes.originalAnime)
                        }
                        
                        self.updateEntityAnimated(changes.originalEntity)
                        if self.shouldReloadAfterEditEnds {
                            self.didReceiveNewList(animelist: CurrentUser.me.cachedAnimeList())
                        }
                    }
                }
                else {
                    changes.revertChanges()
                    if self.shouldReloadAfterEditEnds {
                        self.didReceiveNewList(animelist: CurrentUser.me.cachedAnimeList())
                    }
                    else {
                        self.reloadContent()
                    }
                }
            }
        }
        else {
            completion()
            if self.shouldReloadAfterEditEnds {
                self.didReceiveNewList(animelist: CurrentUser.me.cachedAnimeList())
            }
        }
    }
    
    private func forceUpdateListFromStoredList(newData: Bool) {
        if let animeList = CurrentUser.me.cachedAnimeList() {
            items = animeList.items
            reloadContent()
            if newData {
                searchResultsController?.forceReloadCurrentState()
            }
        }
    }
}

// MARK: - Deeplink
extension HomeAnimeListViewController {
    func canHandleDeeplink() -> Bool {
        return !sortedItems.isEmpty
    }
    
    func forceSelectAnime(identifier: Int) {
        if let indexPath = indexPathForItem(with: identifier) {
            if !sortedItems[indexPath.section].metadata.expanded {
                sectionPressed(indexPath.section)
            }
            
            listDisplayProxy?.flashSelectCell(at: indexPath)
        }
    }
    
    private func indexPathForItem(with identifier: Int) -> IndexPath? {
        for (section, list) in sortedItems.enumerated() {
            for (row, item) in list.items.enumerated() {
                if item.series.identifier == identifier {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
}
