//
//  AnimePreviewViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimePreviewViewController: EntityPreviewViewController {
    @IBOutlet var infosEpisodesLabel: UILabel!
    
    override var analyticsIdentifier: Analytics.View? {
        return .animePreview
    }
    
    override var analyticsEntityType: Analytics.EntityType! {
        return .anime
    }
    
    class func preview(for anime: Anime, delegate: RootViewController?) -> AnimePreviewViewController? {
        if let controller = UIStoryboard(name: "AnimePreview", bundle: nil).instantiateInitialViewController() as? AnimePreviewViewController {
            
            controller.entity = anime
            if let userAnime = CurrentUser.me.cachedAnimeList()?.find(by: anime.identifier) {
                controller.userEntity = userAnime
                controller.changes = AnimeChanges(anime: userAnime)
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
        
        CurrentUser.me.observing.observe(from: self, options: .animeListSynchronized) { [weak self] content in
            switch content {
            case .animeListSynchronized:
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
        if let animelist = CurrentUser.me.cachedAnimeList() {
            if let anime = animelist.find(by: entity.identifier) {
                userEntity = anime
                
                if let changes = changes {
                    changes.originalEntity = anime
                }
                else {
                    changes = AnimeChanges(anime: anime)
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
        
        if let anime = series as? Anime {
            if anime.episodes > 0 {
                metricsLabel.text = "\(anime.episodes) episode\(anime.episodes > 1 ? "s" : "")"
            }
            else {
                metricsLabel.text = "? ep."
            }
        }
    }
    
    override func fillInfosView(withEntityChanges changes: EntityChanges) {
        super.fillInfosView(withEntityChanges: changes)
        
        if let animeChanges = changes as? AnimeChanges {
            infosEpisodesLabel.attributedText = UserAnimeRepresentation.attributedEpisodesCounter(for: animeChanges)
        }
    }
    
    private func displayTitle(for action: Action, isAddToList: Bool) -> String {
        switch action {
        case .completed, .watching, .dropped, .onHold, .planned:
            return UserAnime.Status.displayString(EntityUserStatus(rawValue: action.rawValue)!)
        case .setScore:
            return "Set score..."
        case .setMetrics:
            return "Set watched episodes..."
        case .specialStatus:
            return UserAnime.Status.specialStatus
        case .removeFromList:
            return "Remove from my list"
        }
    }
    
    private func setCompletedEntity(changes: EntityChanges) -> Void {
        if let animeChanges = changes as? AnimeChanges {
            if animeChanges.originalAnime.animeSeries.episodes > 0 {
                animeChanges.watchedEpisodes = animeChanges.originalAnime.animeSeries.episodes
            }
        }
    }
    
    private func selectedIndexesForPicker(changes: EntityChanges) -> [Int]? {
        if let animeChanges = changes as? AnimeChanges {
            return [animeChanges.watchedEpisodes]
        }
        return nil
    }
    
    private func updateEntityWithSelectedIndexes(changes: EntityChanges, indexes: [Int], isAddToList: Bool) -> Void {
        if let animeChanges = changes as? AnimeChanges {
            animeChanges.watchedEpisodes = indexes[safe: 0] ?? 0
            if animeChanges.originalAnime.animeSeries.episodes > 0 &&
                animeChanges.watchedEpisodes >= animeChanges.originalAnime.animeSeries.episodes {
                animeChanges.restarting = false
                if Settings.enableAutomaticDates && animeChanges.originalEntity.status == .planToWatch && animeChanges.originalAnime.startDate == nil {
                    animeChanges.startDate = Date()
                }
                if Settings.enableAutomaticDates && animeChanges.originalAnime.endDate == nil {
                    animeChanges.endDate = Date()
                }
                animeChanges.status = .completed
            }
        }
    }
    
    override func setupActionTableView() {
        guard CurrentUser.me.animeList.editable else {
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
        else if let anime = entity as? Anime {
            setupActionTableView(
                adding: entity,
                changes: AnimeChanges(anime: UserAnime(series: anime)),
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
        
        if let changes = changes as? AnimeChanges, changes.hasChanges() {
            API.updateAnime(changes: changes).request(loadingDelegate: self) { success in
                if success {
                    self.view.makeSuccessToast {
                        SocialNetworkManager.postChanges(changes, fromViewController: self) {
                            changes.commitChanges()
                            CurrentUser.me.updateAnime(changes.originalAnime)
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
        return (entity.series as? Anime).map { API.deleteAnime(anime: $0) }
    }
    
    override func apiAddEntityMethod(entity: EntityChanges) -> API! {
        return (entity as? AnimeChanges).map { API.addAnime(values: $0) }
    }
}
