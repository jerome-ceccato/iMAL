//
//  HomeMangaListViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class HomeMangaListViewController: MangaListViewController {
    override var analyticsIdentifier: Analytics.View? {
        return .userMangaList
    }
    
    override var listStyle: ListDisplayStyle {
        return Settings.listsStyle
    }
    
    override func viewDidLoad() {
        refreshSynchronizationStatus()

        super.viewDidLoad()
        buildSearchController()
        
        CurrentUser.me.observing.observe(from: self, options: [.manga, .mangaRefresh]) { [weak self] content in
            switch content {
            case .mangaAdd, .mangaDelete:
                self?.forceUpdateListFromStoredList(newData: true)
            case .mangaUpdate:
                self?.forceUpdateListFromStoredList(newData: false)
            case .mangaListWillRefresh:
                self?.willSynchronizeList()
            case .mangaListDidRefresh(let new):
                self?.reSynchronizeList(mangalist: new)
            default:
                break
            }
        }

        Settings.handleMangaExpandOptionsUpdatedNotification(self) { [weak self] in
            self?.setCurrentSectionsExpandedState(Settings.mangaStatusSectionState)
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
            let cachedTitle = !CurrentUser.me.mangaList.synchronized && !items.isEmpty
            navigationItem.title = cachedTitle ? "Cached Manga List" : "My Manga List"
        }
    }
    
    override func fill(cell: EntityCell, withEntity entity: UserEntity) {
        if let editableCell = cell as? EditableMangaCell {
            editableCell.delegate = self
        }
        
        super.fill(cell: cell, withEntity: entity)
    }
    
    func didReceiveNewList(mangalist: MangaList?) {
        self.shouldReloadAfterEditEnds = false
        if let mangalist = mangalist {
            if mangalist.items.isEmpty {
                self.emptyListReceived()
            }
            self.setMangaListAndReloadContent(mangalist)
        }
        refreshSynchronizationStatus()
    }
    
    override func remoteReloadList(_ completion: @escaping () -> Void) {
        CurrentUser.me.loadMangaList(option: .alwaysReload, loadingDelegate: self) { mangalist in
            self.didReceiveNewList(mangalist: mangalist)
            completion()
        }
    }
    
    override func loadCachedList() -> Bool {
        if let list = CurrentUser.me.cachedMangaList() {
            setMangaListAndReloadContent(list)
            
            if !CurrentUser.me.mangaList.synchronized {
                willSynchronizeList(canReload: false)
                CurrentUser.me.loadMangaList(option: .reloadIfCached, loadingDelegate: nil, completion: { mangalist in
                    self.reSynchronizeList(mangalist: mangalist)
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
    
    func reSynchronizeList(mangalist: MangaList?) {
        if editingLocked {
            shouldReloadAfterEditEnds = true
        }
        else {
            didReceiveNewList(mangalist: mangalist)
        }
    }
    
    override var areCellsGloballyLocked: Bool {
        return !CurrentUser.me.mangaList.editable
    }
}

extension HomeMangaListViewController: EditableMangaActionDelegate {
    func mangaDidUpdate(_ changes: MangaChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void) {
        updateMangaWithChanges(changes, loadingDelegate: loadingDelegate ?? self, completion: completion)
    }
    
    private func updateMangaWithChanges(_ changes: MangaChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void) {
        if changes.hasChanges() {
            API.updateManga(changes: changes).request(loadingDelegate: loadingDelegate) { success in
                completion()
                if success {
                    loadingDelegate?.view.makeSuccessToast {
                        SocialNetworkManager.postChanges(changes, fromViewController: self)
                        changes.commitChanges()
                        
                        CurrentUser.me.observing.disablingObservation(for: self) {
                            CurrentUser.me.updateManga(changes.originalManga)
                        }
                        
                        self.updateEntityAnimated(changes.originalEntity)
                        if self.shouldReloadAfterEditEnds {
                            self.didReceiveNewList(mangalist: CurrentUser.me.cachedMangaList())
                        }
                    }
                }
                else {
                    changes.revertChanges()
                    if self.shouldReloadAfterEditEnds {
                        self.didReceiveNewList(mangalist: CurrentUser.me.cachedMangaList())
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
                self.didReceiveNewList(mangalist: CurrentUser.me.cachedMangaList())
            }
        }
    }
    
    private func forceUpdateListFromStoredList(newData: Bool) {
        if let mangaList = CurrentUser.me.cachedMangaList() {
            items = mangaList.items
            reloadContent()
            if newData {
                searchResultsController?.forceReloadCurrentState()
            }
        }
    }
}
