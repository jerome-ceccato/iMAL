//
//  MangaPreviewViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaPreviewViewController: EntityPreviewViewController {
    @IBOutlet var infosChaptersLabel: UILabel!
    @IBOutlet var infosVolumesLabel: UILabel!
    
    override var analyticsIdentifier: Analytics.View? {
        return .mangaPreview
    }
    
    override var analyticsEntityType: Analytics.EntityType! {
        return .manga
    }
    
    class func preview(for manga: Manga, delegate: RootViewController?) -> MangaPreviewViewController? {
        if let controller = UIStoryboard(name: "MangaPreview", bundle: nil).instantiateInitialViewController() as? MangaPreviewViewController {
            
            controller.entity = manga
            if let userManga = CurrentUser.me.cachedMangaList()?.find(by: manga.identifier) {
                controller.userEntity = userManga
                controller.changes = MangaChanges(manga: userManga)
            }
            controller.delegate = delegate
            
            controller.transitioningDelegate = controller
            controller.modalPresentationStyle = .custom
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.me.observing.observe(from: self, options: .mangaListSynchronized) { [weak self] content in
            switch content {
            case .mangaListSynchronized:
                self?.updateIfNeeded()
            default:
                break
            }
        }
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    func updateIfNeeded() {
        if let mangalist = CurrentUser.me.cachedMangaList() {
            if let manga = mangalist.find(by: entity.identifier) {
                userEntity = manga
                
                if let changes = changes {
                    changes.originalEntity = manga
                }
                else {
                    changes = MangaChanges(manga: manga)
                }
                
                updateUserInfoIfNeeded()
            }
            else {
                userEntity = nil
                changes = nil
                updateUserInfoIfNeeded()
            }
        }
    }
    
    override func fillSeriesInfosView(withEntity series: Entity) {
        super.fillSeriesInfosView(withEntity: series)
        
        if let manga = series as? Manga {
            metricsLabel.text = MangaMetricsRepresentation.preferredMetricDisplayString(manga: manga)
        }
    }
    
    override func fillInfosView(withEntityChanges changes: EntityChanges) {
        super.fillInfosView(withEntityChanges: changes)
        
        if let mangaChanges = changes as? MangaChanges {
            infosChaptersLabel.attributedText = UserMangaRepresentation.attributedChaptersCounter(for: mangaChanges)
            infosVolumesLabel.attributedText = UserMangaRepresentation.attributedVolumesCounter(for: mangaChanges)
        }
    }
    
    private func displayTitle(for action: Action, isAddToList: Bool) -> String {
        switch action {
        case .completed, .watching, .dropped, .onHold, .planned:
            return UserManga.Status.displayString(EntityUserStatus(rawValue: action.rawValue)!)
        case .setScore:
            return "Set score..."
        case .setMetrics:
            return "Set read volumes/chapters..."
        case .specialStatus:
            return UserManga.Status.specialStatus
        case .removeFromList:
            return "Remove from my list"
        }
    }
    
    private func setCompletedEntity(changes: EntityChanges) -> Void {
        if let mangaChanges = changes as? MangaChanges {
            if mangaChanges.originalManga.mangaSeries.chapters > 0 {
                mangaChanges.readChapters = mangaChanges.originalManga.mangaSeries.chapters
            }
            if mangaChanges.originalManga.mangaSeries.volumes > 0 {
                mangaChanges.readVolumes = mangaChanges.originalManga.mangaSeries.volumes
            }
        }
    }
    
    private func selectedIndexesForPicker(changes: EntityChanges) -> [Int]? {
        if let mangaChanges = changes as? MangaChanges {
            return [mangaChanges.readVolumes, mangaChanges.readChapters]
        }
        return nil
    }
    
    private func updateEntityWithSelectedIndexes(changes: EntityChanges, indexes: [Int], isAddToList: Bool) -> Void {
        if let mangaChanges = changes as? MangaChanges {
            mangaChanges.readVolumes = indexes[safe: 0] ?? 0
            mangaChanges.readChapters = indexes[safe: 1] ?? 0
            if mangaChanges.originalManga.mangaSeries.chapters > 0
                && mangaChanges.originalManga.mangaSeries.volumes > 0
                && mangaChanges.readVolumes >= mangaChanges.originalManga.mangaSeries.volumes
                && mangaChanges.readChapters >= mangaChanges.originalManga.mangaSeries.chapters {
                mangaChanges.restarting = false
                if Settings.enableAutomaticDates && (isAddToList || mangaChanges.originalEntity.status == .planToWatch) && mangaChanges.originalManga.startDate == nil {
                    mangaChanges.startDate = Date()
                }
                if Settings.enableAutomaticDates && mangaChanges.originalManga.endDate == nil {
                    mangaChanges.endDate = Date()
                }
                mangaChanges.status = .completed
            }
        }
    }
    
    override func setupActionTableView() {
        guard CurrentUser.me.mangaList.editable else {
            actionTableViewHeightConstraint.constant = 0
            return
        }
        
        if let changes = changes {
            setupActionTableView(
                updating: changes,
                displayTitle: { action in
                    return self.displayTitle(for: action, isAddToList: false)
            },
                setCompletedEntity: { changes in
                    self.setCompletedEntity(changes: changes)
            },
                selectedIndexesForPicker: { changes in
                    return self.selectedIndexesForPicker(changes: changes)
            },
                updateEntityWithSelectedIndexes: { changes, indexes in
                    self.updateEntityWithSelectedIndexes(changes: changes, indexes: indexes, isAddToList: false)
            })
        }
        else if let manga = entity as? Manga {
            setupActionTableView(
                adding: entity,
                changes: MangaChanges(manga: UserManga(series: manga)),
                displayTitle: { action in
                    return self.displayTitle(for: action, isAddToList: true)
            },
                setCompletedEntity: { changes in
                    self.setCompletedEntity(changes: changes)
            },
                selectedIndexesForPicker: { changes in
                    return self.selectedIndexesForPicker(changes: changes)
            },
                updateEntityWithSelectedIndexes: { changes, indexes in
                    self.updateEntityWithSelectedIndexes(changes: changes, indexes: indexes, isAddToList: true)
            })
        }
    }
    
    override func commitChanges() {
        super.commitChanges()
        
        if let changes = changes as? MangaChanges, changes.hasChanges() {
            API.updateManga(changes: changes).request(loadingDelegate: self) { success in
                if success {
                    self.view.makeSuccessToast {
                        SocialNetworkManager.postChanges(changes, fromViewController: self) {
                            changes.commitChanges()
                            CurrentUser.me.updateManga(changes.originalManga)
                            self.dismissPressed()
                        }
                    }
                }
                else {
                    changes.revertChanges()
                    self.fillInfosView(withEntityChanges: changes)
                }
            }
        }
    }
    
    override func apiDeleteEntityMethod(entity: UserEntity) -> API! {
        return (entity.series as? Manga).map { API.deleteManga(manga: $0) }
    }
    
    override func apiAddEntityMethod(entity: EntityChanges) -> API! {
        return (entity as? MangaChanges).map { API.addManga(values: $0) }
    }
}
