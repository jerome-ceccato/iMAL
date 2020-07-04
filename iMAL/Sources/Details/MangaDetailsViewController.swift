//
//  MangaDetailsViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaDetailsViewController: EntityDetailsViewController {
    var mangaID: Int = 0
    
    @IBOutlet var chaptersUserEntry: EditableChaptersEntryView!
    @IBOutlet var volumesUserEntry: EditableVolumesEntryView!
    
    override var analyticsIdentifier: Analytics.View? {
        return .mangaDetails
    }
    
    override var analyticsEntityType: Analytics.EntityType! {
        return .manga
    }

    class func controller(withMangaID identifier: Int, userData: UserManga? = nil, series: Manga? = nil) -> MangaDetailsViewController? {
        if let controller = UIStoryboard(name: "MangaDetails", bundle: nil).instantiateInitialViewController() as? MangaDetailsViewController {
            controller.mangaID = identifier
            controller.entity = series
            controller.userEntity = userData
            
            return controller
        }
        return nil
    }
    
    class func controller(withRelatedManga relatedManga: RelatedEntity) -> MangaDetailsViewController? {
        if let controller = UIStoryboard(name: "MangaDetails", bundle: nil).instantiateInitialViewController() as? MangaDetailsViewController {
            controller.mangaID = relatedManga.mangaIdentifier!
            if let manga = CurrentUser.me.cachedMangaList()?.find(by: controller.mangaID) {
                controller.userEntity = manga
            }
            else {
                controller.entity = Manga(related: relatedManga)
            }
            
            return controller
        }
        return nil
    }
    
    override var userEntityListIsEditable: Bool {
        return CurrentUser.me.mangaList.editable
    }
    
    override func apiGetEntityMethod() -> API! {
        return API.getMangaDetails(mangaID: mangaID)
    }
    
    override func additionAvailableStatusesDisplayStrings() -> [String] {
        return UserManga.Status.displayStrings.filter { $0 != UserManga.Status.specialStatus }
    }
    
    override func entityStatus(for status: String?) -> EntityUserStatus {
        if let status = status {
            return UserManga.Status.statusForDisplayString(status)
        }
        return .unknown
    }
    
    override var originalTitleDisplayLabel: String {
        if let type = (userEntity?.series.type ?? entity?.type) as? MangaType {
            switch type {
            case .manhua:
                return "Chinese"
            case .manhwa:
                return "Korean"
            default:
                break
            }
        }
        return "Japanese"
    }
    
    var safeMangaID: Int {
        return self.mangaID != 0 ? self.mangaID : (userEntity?.series ?? entity)?.identifier ?? 0
    }
    
    override func apiGetPicturesMethod() -> API! {
        return API.getMangaPictures(mangaID: safeMangaID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.me.observing.observe(from: self, options: [.manga, .mangaListSynchronized]) { [weak self] content in
            switch content {
            case .mangaListSynchronized, .mangaAdd, .mangaUpdate, .mangaDelete:
                self?.updateIfNeededAfterSynchronization()
            default:
                break
            }
        }
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    func updateIfNeededAfterSynchronization() {
        if let mangalist = CurrentUser.me.cachedMangaList(), let manga = mangalist.find(by: safeMangaID) {
            userEntity = manga
            updateUserEntityValues(manga)
            
            if entityListStatus == .unknown || entityListStatus == .notInList {
                entityListStatus = .inList
                updateFieldsVisibility(with: entityListStatus)
            }
        }
        else {
            if entityListStatus == .unknown || entityListStatus == .inList {
                entityListStatus = .notInList
                if entity == nil {
                    entity = userEntity?.series
                }
                userEntity = nil
                updateFieldsVisibility(with: entityListStatus)
            }
        }
    }
    
    // MARK: - Add
    
    override func apiAddEntityMethod(changes: EntityChanges) -> API! {
        return API.addManga(values: changes as! MangaChanges)
    }
    
    override func changesForNewEntity(with status: EntityUserStatus) -> EntityChanges! {
        let changes = MangaChanges(manga: UserManga(series: entity as! Manga))
        
        changes.status = status
        switch status {
        case .watching, .onHold, .dropped:
            if Settings.enableAutomaticDates {
                changes.startDate = Date()
            }
        case .completed:
            if Settings.enableAutomaticDates {
                changes.startDate = Date()
                changes.endDate = Date()
            }
            if changes.originalManga.mangaSeries.chapters > 0 {
                changes.readChapters = changes.originalManga.mangaSeries.chapters
            }
            if changes.originalManga.mangaSeries.volumes > 0 {
                changes.readVolumes = changes.originalManga.mangaSeries.volumes
            }
        default:
            break
        }
        
        return changes
    }
    
    // MARK: - Delete
    
    override func apiDeleteEntityMethod() -> API! {
        let manga = (userEntity as? UserManga)?.mangaSeries
        return API.deleteManga(manga: manga!)
    }
    
    // MARK: - Content
    
    override func setupEditingCoordinator() {
        editingCoordinator = MangaEditingCoordinator(delegate: self)
        
        super.setupEditingCoordinator()
        
        let mangaCoordinator = editingCoordinator as! MangaEditingCoordinator
        mangaCoordinator.chaptersUserEntry = chaptersUserEntry
        mangaCoordinator.volumesUserEntry = volumesUserEntry
    }
    
    override func updateUserEntityValues(_ entity: UserEntity) {
        if let userEntity = entity as? UserManga, let editingCoordinator = editingCoordinator as? MangaEditingCoordinator {
            editingCoordinator.updateFields(with: userEntity)
        }
    }
    
    override func loadAdditionalContent() {
        super.loadAdditionalContent()
        
        if let series = (entity ?? userEntity?.series) as? Manga {
            buildSectionStackView(withContainer: informationStackContainerView, data: [
                ("Type", series.type.displayString),
                ("Status", series.status.displayString),
                ("Chapters", series.chapters > 0 ? "\(series.chapters)" : "?"),
                ("Volumes", series.volumes > 0 ? "\(series.volumes)" : "?"),
                ("Published", series.airingDatesDisplayString),
                ("Genres", series.genres.joined(separator: ", ")),
                ("Authors", series.authorsDisplayString),
                ("Serialization", series.serialization)])
        }
        
        self.mainContainersHiddenView.forEach {
            $0.alpha = 0
            $0.isHidden = false
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.mainContainersHiddenView.forEach { $0.alpha = 1 }
        }) 
    }
    
    // MARK: - Actions
    
    override func setupMoreInfosActionSheetAdditionalData(actionSheet: ManagedActionSheetViewController) {
        actionSheet.addAction(ManagedActionSheetAction(title: "Characters", style: .default, action: {
            self.showCastPressed()
        }))
    }
    
    @IBAction func showCastPressed() {
        if let manga = entity as? Manga ?? (userEntity as? UserManga)?.mangaSeries {
            if let controller = EntityCastViewController.controller(withEntity: TypedEntity(entity: manga, kind: .manga)) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction override func showReviewsPressed() {
        if let manga = entity as? Manga ?? (userEntity as? UserManga)?.mangaSeries {
            if let controller = EntityReviewViewController.controller(withEntity: TypedEntity(entity: manga, kind: .manga)) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction override func showRecommendationsPressed() {
        if let manga = entity as? Manga ?? (userEntity as? UserManga)?.mangaSeries {
            if let controller = RecommendationsViewController.controller(withEntity: TypedEntity(entity: manga, kind: .manga)) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

}

