//
//  AnimeDetailsViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 22/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimeDetailsViewController: EntityDetailsViewController {
    var animeID: Int = 0
  
    @IBOutlet var episodesUserEntry: EditableEpisodesEntryView!
    
    @IBOutlet var themesContainerView: UIView!
    @IBOutlet var themesContentView: UIView!

    override var analyticsIdentifier: Analytics.View? {
        return .animeDetails
    }
    
    override var analyticsEntityType: Analytics.EntityType! {
        return .anime
    }

    class func controller(withAnimeID identifier: Int, userData: UserAnime? = nil, series: Anime? = nil) -> AnimeDetailsViewController? {
        if let controller = UIStoryboard(name: "AnimeDetails", bundle: nil).instantiateInitialViewController() as? AnimeDetailsViewController {
            controller.animeID = identifier
            controller.entity = series
            controller.userEntity = userData
            
            return controller
        }
        return nil
    }
    
    class func controller(withRelatedAnime relatedAnime: RelatedEntity) -> AnimeDetailsViewController? {
        if let controller = UIStoryboard(name: "AnimeDetails", bundle: nil).instantiateInitialViewController() as? AnimeDetailsViewController {
            controller.animeID = relatedAnime.animeIdentifier!
            if let anime = CurrentUser.me.cachedAnimeList()?.find(by: controller.animeID) {
                controller.userEntity = anime
            }
            else {
                controller.entity = Anime(related: relatedAnime)
            }
            
            return controller
        }
        return nil
    }
    
    override var userEntityListIsEditable: Bool {
        return CurrentUser.me.animeList.editable
    }
    
    override func apiGetEntityMethod() -> API! {
        return API.getAnimeDetails(animeID: animeID)
    }
    
    override func additionAvailableStatusesDisplayStrings() -> [String] {
        return UserAnime.Status.displayStrings.filter { $0 != UserAnime.Status.specialStatus }
    }
    
    override func entityStatus(for status: String?) -> EntityUserStatus {
        if let status = status {
            return UserAnime.Status.statusForDisplayString(status)
        }
        return .unknown
    }
    
    var safeAnimeID: Int {
        return self.animeID != 0 ? self.animeID : (userEntity?.series ?? entity)?.identifier ?? 0
    }
    
    override func apiGetPicturesMethod() -> API! {
        return API.getAnimePictures(animeID: safeAnimeID)
    }
    
    override func preloadContent(withEntity entity: Entity) {
        super.preloadContent(withEntity: entity)
        if let anime = entity as? Anime, let status = AiringDataRepresentation.animeAiringDataDisplayString(for: anime) {
            statusLabel.attributedText = status
        }
    }
    
    override func preloadContent(withUserEntity entity: UserEntity) {
        super.preloadContent(withUserEntity: entity)
        if let anime = entity as? UserAnime, let status = AiringDataRepresentation.userAnimeAiringDataDisplayString(for: anime) {
            statusLabel.attributedText = status
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.me.observing.observe(from: self, options: [.anime, .animeListSynchronized]) { [weak self] content in
            switch content {
            case .animeListSynchronized, .animeAdd, .animeUpdate, .animeDelete:
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
        if let animelist = CurrentUser.me.cachedAnimeList(), let anime = animelist.find(by: safeAnimeID) {
            userEntity = anime
            updateUserEntityValues(anime)

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
        return API.addAnime(values: changes as! AnimeChanges)
    }

    override func changesForNewEntity(with status: EntityUserStatus) -> EntityChanges! {
        let changes = AnimeChanges(anime: UserAnime(series: entity as! Anime))
        
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
            if changes.originalAnime.animeSeries.episodes > 0 {
                changes.watchedEpisodes = changes.originalAnime.animeSeries.episodes
            }
        default:
            break
        }
        
        return changes
    }
    
    // MARK: - Delete
    
    override func apiDeleteEntityMethod() -> API! {
        let anime = (userEntity as? UserAnime)?.animeSeries
        return API.deleteAnime(anime: anime!)
    }

    // MARK: - Content

    override func setupEditingCoordinator() {
        editingCoordinator = AnimeEditingCoordinator(delegate: self)
        
        super.setupEditingCoordinator()
        
        let animeCoordinator = editingCoordinator as! AnimeEditingCoordinator
        animeCoordinator.episodesUserEntry = episodesUserEntry
    }
    
    override func updateUserEntityValues(_ entity: UserEntity) {
        if let userEntity = entity as? UserAnime, let editingCoordinator = editingCoordinator as? AnimeEditingCoordinator {
            editingCoordinator.updateFields(with: userEntity)
        }
    }
    
    override func loadAdditionalContent() {
        super.loadAdditionalContent()
        
        if let series = (entity ?? userEntity?.series) as? Anime {
            let data:[(String, String?)] = [
                ("Type", series.type.displayString),
                ("Status", series.status.displayString),
                ("Episodes", series.episodes > 0 ? "\(series.episodes)" : "?"),
                ("Duration", series.durationDisplayString),
                ("Aired", series.airingDatesDisplayString),
                ("Rating", series.classification),
                ("Source", series.source),
                ("Genres", series.genres.joined(separator: ", ")),
                ("Producers", series.producers.joined(separator: ", ")),
                ("Licensors", series.licensors.joined(separator: ", ")),
                ("Studios", series.studios.joined(separator: ", "))
            ]

            if !series.openingThemes.isEmpty || !series.endingThemes.isEmpty {
                buildThemesContentView(with: series)
            }
            else {
                forceHideEmptyContainerView(themesContainerView)
            }
            buildSectionStackView(withContainer: informationStackContainerView, data: data)
        }
        
        self.mainContainersHiddenView.forEach {
            $0.alpha = 0
            $0.isHidden = false
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.mainContainersHiddenView.forEach { $0.alpha = 1 }
        }) 
    }
    
    func buildThemesContentView(with series: Anime) {
        var views: [UIView] = []
        if !series.openingThemes.isEmpty {
            views.append(contentsOf: buildThemeSection(with: series.openingThemes, title: "Opening\(series.openingThemes.count > 1 ? "s" : "")"))
        }
        if !series.endingThemes.isEmpty {
            views.append(contentsOf: buildThemeSection(with: series.endingThemes, title: "Ending\(series.endingThemes.count > 1 ? "s" : "")"))
        }
        
        buildStackView(themesContentView, contentViews: views, hiddenViews: [])
    }
    
    func buildThemeSection(with data: [String], title: String) -> [UIView] {
        var views: [UIView] = [EntityDetailsThemeTitleRowView.build(with: title)]
        views.append(contentsOf: data.map({ EntityDetailsThemeEntryRowView.build(with: $0) }))
        return views
    }
    
    // MARK: - Actions
    
    override func setupMoreInfosActionSheetAdditionalData(actionSheet: ManagedActionSheetViewController) {
        if let preview = (entity as? Anime ?? (userEntity as? UserAnime)?.animeSeries)?.previewURL {
            if let url = URL(string: preview) {
                actionSheet.addAction(ManagedActionSheetAction(title: "Preview", style: .default, action: { 
                    url.open(in: self)
                }))
                
                actionSheet.addAction(ManagedActionSheetAction(title: "", style: .separator, action: nil))
            }
        }
        
        actionSheet.addAction(ManagedActionSheetAction(title: "Characters & Staff", style: .default, action: { 
            self.showCastPressed()
        }))
        
        actionSheet.addAction(ManagedActionSheetAction(title: "Episodes", style: .default, action: { 
            self.showEpisodesPressed()
        }))
    }
    
    @IBAction func showEpisodesPressed() {
        if let anime = entity as? Anime ?? (userEntity as? UserAnime)?.animeSeries {
            if let controller = AnimeEpisodesViewController.controller(withAnime: anime) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction func showCastPressed() {
        if let anime = entity as? Anime ?? (userEntity as? UserAnime)?.animeSeries {
            if let controller = EntityCastViewController.controller(withEntity: TypedEntity(entity: anime, kind: .anime)) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction override func showReviewsPressed() {
        if let anime = entity as? Anime ?? (userEntity as? UserAnime)?.animeSeries {
            if let controller = EntityReviewViewController.controller(withEntity: TypedEntity(entity: anime, kind: .anime)) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction override func showRecommendationsPressed() {
        if let anime = entity as? Anime ?? (userEntity as? UserAnime)?.animeSeries {
            if let controller = RecommendationsViewController.controller(withEntity: TypedEntity(entity: anime, kind: .anime)) {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
