//
//  EntityPreviewProtocol
//  iMAL
//
//  Created by Jérôme Ceccato on 04/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol EntityPreviewProtocolAnimating: class {
    var backgroundScreenshotView: UIImageView! { get }
    var backgroundScreenshotBlurOverlay: UIView? { get set }
    var contentContainerView: UIView! { get }
}

extension EntityPreviewProtocolAnimating {
    func setupBlurOverlay() {
        let theme = ThemeManager.currentTheme
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurContainerView = UIView(frame: backgroundScreenshotView.bounds)
            blurContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let blurEffect = UIBlurEffect(style: theme.previewPopup.blurEffect.style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)

            blurEffectView.frame = backgroundScreenshotView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let overlayEffect = UIView(frame: backgroundScreenshotView.bounds)
            overlayEffect.backgroundColor = theme.previewPopup.blurOverlay.color
            overlayEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            blurContainerView.addSubview(overlayEffect)
            blurContainerView.addSubview(blurEffectView)
            
            backgroundScreenshotView.addSubview(blurContainerView)
            backgroundScreenshotBlurOverlay = blurContainerView
        }
        else {
            let overlayEffect = UIView(frame: backgroundScreenshotView.bounds)
            overlayEffect.backgroundColor = theme.previewPopup.blurOverlay.color
            overlayEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            backgroundScreenshotView.addSubview(overlayEffect)
            backgroundScreenshotBlurOverlay = overlayEffect
        }
    }
}

class EntityPreviewViewController: RootViewController, EntityPreviewProtocolAnimating {
    @IBOutlet var backgroundScreenshotView: UIImageView!
    @IBOutlet var contentContainerView: UIView!
    var backgroundScreenshotBlurOverlay: UIView?
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var contentScrollView: UIScrollView!
    @IBOutlet var viewDetailsButton: UIButton!
    
    @IBOutlet var infosTitleLabel: UILabel!
    @IBOutlet var infosPictureImageView: UIImageView!

    @IBOutlet var entityInListInfoContentView: UIView!
    @IBOutlet var infosStatusLabel: UILabel!
    @IBOutlet var infosScoreLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var tagsInvisibleConstraint: NSLayoutConstraint!
    
    @IBOutlet var entityNotInListInfoContentView: UIView!
    @IBOutlet var notInListLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var metricsLabel: UILabel!
    
    @IBOutlet var entityInfosContainerView: UIView!
    @IBOutlet var actionsInfosContainerView: UIView!
    @IBOutlet var actionTableView: ManagedTableView!
    @IBOutlet var actionTableViewHeightConstraint: NSLayoutConstraint!
    
    private var isSetup: Bool = false
    weak var delegate: RootViewController?
    
    var entity: Entity!
    var userEntity: UserEntity?
    var changes: EntityChanges?
    
    var currentPicker: EntityPreviewPickerView?

    class func preview(for entity: Entity, delegate: RootViewController?) -> EntityPreviewViewController? {
        if let entity = entity as? Anime {
            return AnimePreviewViewController.preview(for: entity, delegate: delegate)
        }
        else if let entity = entity as? Manga {
            return MangaPreviewViewController.preview(for: entity, delegate: delegate)
        }
        return nil
    }
    
    var analyticsEntityType: Analytics.EntityType! {
        return nil
    }
    
    @IBAction func dismissPressed() {
        currentPicker?.animateDisappear(animateAlongside: nil, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func dismissAfterUpdate() {
        view.makeSuccessToast {
            self.dismissPressed()
        }
    }
    
    @IBAction func showDetailsPressed() {
        dismissPressed()
        delegate?.pushEntityDetailsViewController(for: entity)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        entityInfosContainerView.layer.cornerRadius = 12
        entityInfosContainerView.layer.masksToBounds = true
        
        actionsInfosContainerView.layer.cornerRadius = 12
        actionsInfosContainerView.layer.masksToBounds = true
        
        infosPictureImageView.layer.cornerRadius = 3
        infosPictureImageView.layer.masksToBounds = true
        
        fillSeriesInfosView(withEntity: entity)
        updateUserInfoIfNeeded()
        
        applyTheme { [unowned self] theme in
            self.headerView.backgroundColor = theme.previewPopup.header.color
            self.entityInfosContainerView.backgroundColor = theme.previewPopup.background.color
            self.actionsInfosContainerView.backgroundColor = theme.previewPopup.background.color
            self.infosTitleLabel.textColor = theme.entity.name.color
            self.infosStatusLabel.textColor = theme.entity.status.color
            self.tagsLabel.textColor = theme.entity.tags.color
            self.typeLabel.textColor = theme.entity.type.color
            self.notInListLabel.textColor = theme.entity.label.color
            self.metricsLabel.textColor = theme.entity.metrics.color
            self.viewDetailsButton.setTitleColor(theme.global.actionButton.color, for: .normal)
        }
    }
    
    func updateUserInfoIfNeeded() {
        if let userEntity = userEntity {
            entityInListInfoContentView.isHidden = false
            entityNotInListInfoContentView.isHidden = true
            
            fillTags(withEntity: userEntity)
        }
        else {
            entityInListInfoContentView.isHidden = true
            entityNotInListInfoContentView.isHidden = false
            
            hideTags(hide: true)
        }
        
        if let changes = changes {
            fillInfosView(withEntityChanges: changes)
        }
        setupActionTableView()
    }
    
    func fillSeriesInfosView(withEntity series: Entity) {
        infosTitleLabel.text = series.name
        infosPictureImageView.setImageWithURLString(series.pictureURL)
        
        typeLabel.text = series.type.displayString
    }
    
    func fillTags(withEntity entity: UserEntity) {
        if entity.tags.isEmpty {
            hideTags(hide: true)
        }
        else {
            hideTags(hide: false)
            tagsLabel.text = "Tags: " + entity.tags.joined(separator: ", ")
        }
    }
    
    func hideTags(hide: Bool) {
        tagsLabel.isHidden = hide
        tagsInvisibleConstraint.priority = hide ? UILayoutPriority.defaultLow : UILayoutPriority.required - 1
    }
    
    func fillInfosView(withEntityChanges changes: EntityChanges) {
        infosScoreLabel.attributedText = UserEntityAttributedRepresentation.attributedDisplayString(forScore: changes.score)
        infosStatusLabel.text = changes.specialStatus ?? changes.statusDisplayString
    }
    
    func setupActionTableView() {}
    
    func commitChanges() {
        if let changes = changes {
            fillInfosView(withEntityChanges: changes)
        }
    }
    
    func performPreviewAction(_ action: EntityPreviewAction) {
        action.action()
    }
    
    func apiDeleteEntityMethod(entity: UserEntity) -> API! {
        return nil
    }
    
    func removeFromList(entity: UserEntity) {
        apiDeleteEntityMethod(entity: entity).request(loadingDelegate: self) { success in
            if success {
                self.view.makeSuccessToast() {
                    self.dismissPressed()
                }
                CurrentUser.me.deleteEntity(entity)
            }
        }
    }
    
    func apiAddEntityMethod(entity: EntityChanges) -> API! {
        return nil
    }
    
    func addToList(changes: EntityChanges) {
        apiAddEntityMethod(entity: changes).request(loadingDelegate: self) { success in
            if success {
                self.view.makeSuccessToast {
                    SocialNetworkManager.postChanges(changes, fromViewController: self) {
                        changes.commitChanges()
                        CurrentUser.me.addEntity(changes.originalEntity)
                        self.dismissPressed()
                    }
                }
            }
        }
    }
}

private extension EntityPreviewViewController {
    func showPicker(withDisplayData data: [[String]], selectedIndexes: [Int]?, handler: @escaping ([Int]) -> Void) {
        currentPicker = EntityPreviewPickerView.picker(withDisplayData: data, selectedIndexes: selectedIndexes, handler: { (picker, save, indexes) in
            picker.animateDisappear(
                animateAlongside: {
                    self.actionsInfosContainerView.alpha = 1
                },
                completion: nil)
            
            if save {
                handler(indexes)
            }
            else if let changes = self.changes {
                changes.revertChanges()
                self.fillInfosView(withEntityChanges: changes)
            }
        })
        currentPicker?.animeAppear(in: self, animateAlongside: {
            self.contentScrollView.contentOffset = CGPoint.zero
            self.actionsInfosContainerView.alpha = 0
        })
    }
    
    func askRemove(entity: Entity, completion: @escaping () -> Void) {
        let entityTitle = entity.name
        
        let alert = UIAlertController(title: nil, message: "Are you sure you want to remove \"\(entityTitle)\" from your list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
            completion()
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension EntityPreviewViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return EntityPreviewTransitionController(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return EntityPreviewTransitionController(presenting: false)
    }
}

extension EntityPreviewViewController {
    enum Action: Int {
        case watching = 1
        case completed = 2
        case onHold = 3
        case dropped = 4
        case planned = 6

        case setMetrics = 1001
        case specialStatus = 1002
        case setScore = 1003
        case removeFromList = 1004
    }
    
    func trackAction(_ action: Action) {
        Analytics.track(event: .previewAction(analyticsEntityType, action))
    }
    
    func setupActionTableView(updating changes: EntityChanges,
                              displayTitle: (Action) -> String,
                              setCompletedEntity: @escaping (EntityChanges) -> Void,
                              selectedIndexesForPicker: @escaping (EntityChanges) -> [Int]?,
                              updateEntityWithSelectedIndexes: @escaping (EntityChanges, [Int]) -> Void) {
        guard !isSetup else {
            return
        }
        
        let entity = changes.originalEntity!
        var actions = [EntityPreviewAction]()
        
        if entity.status == .watching || entity.restarting {
            actions.append(EntityPreviewAction(title: displayTitle(.setMetrics), action: {
                self.trackAction(.setMetrics)
                
                self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: entity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                    updateEntityWithSelectedIndexes(changes, indexes)
                    
                    self.commitChanges()
                })
            }))
        }
        
        if ![EntityUserStatus.watching, EntityUserStatus.completed].contains(entity.status) {
            actions.append(EntityPreviewAction(title: displayTitle(.watching), action: {
                self.trackAction(.watching)
                changes.status = .watching
                
                if entity.status == .planToWatch {
                    if Settings.enableAutomaticDates && changes.originalEntity.startDate == nil {
                        changes.startDate = Date()
                    }
                    self.fillInfosView(withEntityChanges: changes)
                    self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: entity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                        updateEntityWithSelectedIndexes(changes, indexes)
                        
                        self.commitChanges()
                    })
                }
                else {
                    self.commitChanges()
                }
            }))
        }
        
        if [EntityUserStatus.watching, EntityUserStatus.planToWatch].contains(entity.status) || entity.restarting {
            actions.append(EntityPreviewAction(title: displayTitle(.completed), action: {
                self.trackAction(.completed)
                setCompletedEntity(changes)
                
                changes.restarting = false
                if Settings.enableAutomaticDates && entity.status == .planToWatch && changes.originalEntity.startDate == nil {
                    changes.startDate = Date()
                }
                if Settings.enableAutomaticDates && changes.originalEntity.endDate == nil {
                    changes.endDate = Date()
                }
                changes.status = .completed
                
                self.fillInfosView(withEntityChanges: changes)
                
                let scores = Int.scoresDisplayStrings().map { $0.isEmpty ? "None" : $0 }
                self.showPicker(withDisplayData: [scores], selectedIndexes: [changes.score], handler: { indexes in
                    changes.score = indexes[0]
                    
                    self.commitChanges()
                })
            }))
        }

        if [EntityUserStatus.watching, EntityUserStatus.dropped, EntityUserStatus.planToWatch].contains(entity.status) {
            actions.append(EntityPreviewAction(title: displayTitle(.onHold), action: {
                self.trackAction(.onHold)
                
                changes.status = .onHold
                if entity.status == .planToWatch {
                    self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: entity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                        updateEntityWithSelectedIndexes(changes, indexes)
                        
                        self.commitChanges()
                    })
                }
                else {
                    self.commitChanges()
                }
            }))
        }
        
        if ![EntityUserStatus.dropped, EntityUserStatus.completed].contains(entity.status) {
            actions.append(EntityPreviewAction(title: displayTitle(.dropped), action: {
                self.trackAction(.dropped)
                    
                changes.status = .dropped
                if entity.status == .planToWatch {
                    self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: entity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                        updateEntityWithSelectedIndexes(changes, indexes)
                        
                        self.commitChanges()
                    })
                }
                else {
                    self.commitChanges()
                }
            }))
        }
        
        if entity.status == .completed {
            if !entity.restarting {
                actions.append(EntityPreviewAction(title: displayTitle(.specialStatus), action: {
                    self.trackAction(.specialStatus)
                    
                    changes.restarting = true
                    updateEntityWithSelectedIndexes(changes, [])
                    self.fillInfosView(withEntityChanges: changes)
                    self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: entity, forceAbsolute: true), selectedIndexes: nil, handler: { indexes in
                        updateEntityWithSelectedIndexes(changes, indexes)
                        
                        self.commitChanges()
                    })
                }))
            }
            
            actions.append(EntityPreviewAction(title: displayTitle(.setScore), action: {
                self.trackAction(.setScore)
                
                let scores = Int.scoresDisplayStrings().map { $0.isEmpty ? "None" : $0 }
                self.showPicker(withDisplayData: [scores], selectedIndexes: [changes.score], handler: { indexes in
                    changes.score = indexes[0]
                    
                    self.commitChanges()
                })
            }))
        }
        
        if entity.status == .planToWatch {
            actions.append(EntityPreviewAction(title: displayTitle(.removeFromList), destructive: true, action: {
                self.askRemove(entity: entity.series, completion: {
                    self.trackAction(.removeFromList)
                    self.removeFromList(entity: entity)
                })
            }))
        }
        
        actionTableView.setup(withSimpleData: actions, rowHeight: 64, selectAction: { [weak self] action in
            if let action = action as? EntityPreviewAction {
                self?.performPreviewAction(action)
            }
        })
        isSetup = true
    }
    
    func setupActionTableView(adding entity: Entity,
                              changes: EntityChanges,
                              displayTitle: (Action) -> String,
                              setCompletedEntity: @escaping (EntityChanges) -> Void,
                              selectedIndexesForPicker: @escaping (EntityChanges) -> [Int]?,
                              updateEntityWithSelectedIndexes: @escaping (EntityChanges, [Int]) -> Void) {
        guard !isSetup else {
            return
        }
        
        var actions = [EntityPreviewAction]()
        actions.append(EntityPreviewAction(title: displayTitle(.watching), action: {
            self.trackAction(.watching)
            
            changes.status = .watching
            if Settings.enableAutomaticDates {
                changes.startDate = Date()
            }
            
            self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: changes.originalEntity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                updateEntityWithSelectedIndexes(changes, indexes)
                
                self.addToList(changes: changes)
            })
        }))
        
        actions.append(EntityPreviewAction(title: displayTitle(.completed), action: {
            self.trackAction(.completed)
            
            changes.status = .completed
            if Settings.enableAutomaticDates {
                changes.startDate = Date()
                changes.endDate = Date()
            }
            setCompletedEntity(changes)
            
            let scores = Int.scoresDisplayStrings().map { $0.isEmpty ? "None" : $0 }
            self.showPicker(withDisplayData: [scores], selectedIndexes: [changes.score], handler: { indexes in
                changes.score = indexes[0]
                
                self.addToList(changes: changes)
            })
        }))
        
        actions.append(EntityPreviewAction(title: displayTitle(.onHold), action: {
            self.trackAction(.onHold)
            
            changes.status = .onHold
            if Settings.enableAutomaticDates {
                changes.startDate = Date()
            }
            
            self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: changes.originalEntity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                updateEntityWithSelectedIndexes(changes, indexes)
                
                self.addToList(changes: changes)
            })
        }))
        
        actions.append(EntityPreviewAction(title: displayTitle(.dropped), action: {
            self.trackAction(.dropped)
            
            changes.status = .dropped
            if Settings.enableAutomaticDates {
                changes.startDate = Date()
            }
            
            self.showPicker(withDisplayData: UserEntityEditingPickerRepresentation.editingPickerDisplayData(userEntity: changes.originalEntity), selectedIndexes: selectedIndexesForPicker(changes), handler: { indexes in
                updateEntityWithSelectedIndexes(changes, indexes)
                
                self.addToList(changes: changes)
            })
        }))
        
        actions.append(EntityPreviewAction(title: displayTitle(.planned), action: {
            self.trackAction(.planned)
            
            changes.status = .planToWatch
            
            self.addToList(changes: changes)
        }))
        
        actionTableView.setup(withSimpleData: actions, rowHeight: 64, selectAction: { [weak self] action in
            if let action = action as? EntityPreviewAction {
                self?.performPreviewAction(action)
            }
        })
        isSetup = true
    }
}
