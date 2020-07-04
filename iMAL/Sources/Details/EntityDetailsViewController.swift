//
//  EntityDetailsViewControllerProtocol.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 22/08/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import INSPhotoGallery

class EntityDetailsViewController: RootViewController {
    enum EntityListStatus: Int {
        case unknown
        case inList
        case notInList
    }
    
    var entity: Entity?
    var userEntity: UserEntity?
    var hasDetailedContent: Bool = false
    
    var allPictureURLs: [String]?
    
    var baseScrollViewBottomInset: CGFloat?
    var keyboardIsVisible: Bool = false
    
    var regularLeftNavigationButton: UIBarButtonItem?
    var regularRightNavigationButton: UIBarButtonItem?
    
    var entityListStatus: EntityListStatus = .unknown
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainContainerView: UIView!
    
    @IBOutlet var topContainerView: UIView!
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var topSeparatorView: UIView!
    
    @IBOutlet var userContainerView: UIView!
    @IBOutlet var statusUserEntry: EditableStatusEntryView!
    @IBOutlet var scoreUserEntry: EditableScoreEntryView!
    @IBOutlet var startDateUserEntry: EditableDateEntryView!
    @IBOutlet var endDateUserEntry: EditableDateEntryView!
    @IBOutlet var tagsUserEntry: EditableTagsEntryView!
    
    @IBOutlet var additionalInfosLoadingView: UIActivityIndicatorView!
    
    @IBOutlet var addEntityContainerView: UIView!
    @IBOutlet var addEntityButton: UIButton!
    
    @IBOutlet var userContentShowMoreButton: UIButton!
    @IBOutlet var userContentShowMoreLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var userContentViews: [UIView]!
    @IBOutlet var userContentHiddenViews: [UIView]!
    var userContentIsShowingExtra: Bool = false
    
    @IBOutlet var mainContainersView: [UIView]!
    @IBOutlet var mainContainersHiddenView: [UIView]!
    
    @IBOutlet var alternativeTitlesContainerView: UIView!
    @IBOutlet var alternativeTitlesStackContainerView: UIView!
    
    @IBOutlet var informationContainerView: UIView!
    @IBOutlet var informationStackContainerView: UIView!
    
    @IBOutlet var statisticsContainerView: UIView!
    @IBOutlet var statisticsStackContainerView: UIView!
    
    @IBOutlet var synopsisContainerView: UIView!
    @IBOutlet var synopsisLabel: UILabel!
    
    @IBOutlet var backgroundContainerView: UIView!
    @IBOutlet var backgroundLabel: UILabel!
    
    @IBOutlet var relatedContainerView: UIView!
    @IBOutlet var relatedManagedTableView: ManagedTableView!
    
    @IBOutlet var moreInfoContainerView: UIView!
    @IBOutlet var moreInfoButtons: [UIButton]!
    
    @IBOutlet var deleteContainerView: UIView!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var viewOnMALButton: UIButton!
    
    @IBOutlet var themableSectionTitles: [UILabel]!
    
    var editingCoordinator: EntityEditingCoordinator!

    class func controller(for entity: Entity) -> EntityDetailsViewController? {
        if let entity = entity as? Anime {
            if let mine = CurrentUser.me.cachedAnimeList()?.find(by: entity.identifier) {
                return AnimeDetailsViewController.controller(withAnimeID: entity.identifier, userData: mine)
            }
            else {
                return AnimeDetailsViewController.controller(withAnimeID: entity.identifier, series: entity)
            }
        }
        else if let entity = entity as? Manga {
            if let mine = CurrentUser.me.cachedMangaList()?.find(by: entity.identifier) {
                return MangaDetailsViewController.controller(withMangaID: entity.identifier, userData: mine)
            }
            else {
                return MangaDetailsViewController.controller(withMangaID: entity.identifier, series: entity)
            }
        }
        return nil
    }
    
    var analyticsEntityType: Analytics.EntityType! {
        return nil
    }
    
    func setupEditingCoordinator() {
        editingCoordinator.statusUserEntry = statusUserEntry
        editingCoordinator.scoreUserEntry = scoreUserEntry
        editingCoordinator.startDateUserEntry = startDateUserEntry
        editingCoordinator.endDateUserEntry = endDateUserEntry
        editingCoordinator.tagsUserEntry = tagsUserEntry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userEntityListIsEditable {
            entityListStatus = userEntity != nil ? .inList : .notInList
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.additionalInfosLoadingView.activityIndicatorViewStyle = theme.global.loadingIndicators.regular.style
            
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.titleLabel.textColor = theme.entity.name.color
            self.typeLabel.textColor = theme.entity.type.color
            self.statusLabel.textColor = theme.entity.status.color
            
            self.viewOnMALButton.setTitleColor(theme.global.link.color, for: .normal)
            
            self.userContentShowMoreButton.setTitleColor(theme.global.link.color, for: .normal)
            self.userContentShowMoreLoadingIndicator.activityIndicatorViewStyle = theme.global.loadingIndicators.regular.style
            
            (self.moreInfoButtons + self.addEntityButton!).forEach { actionButton in
                actionButton.setTitleColor(theme.global.actionButton.color, for: .normal)
                actionButton.layer.borderColor = theme.global.actionButton.color.cgColor
            }
            
            [self.deleteButton!].forEach { destructiveButton in
                destructiveButton.setTitleColor(theme.global.destructiveButton.color, for: .normal)
                destructiveButton.layer.borderColor = theme.global.destructiveButton.color.cgColor
            }
            
            self.themableSectionTitles.forEach { label in
                label.textColor = theme.detailsView.sectionTitle.color
            }
            
            if self.hasDetailedContent, let entity = self.entity ?? self.userEntity?.series {
                self.setSynopsisAndBackground(from: entity)
            }
            
            self.relatedManagedTableView.reloadData()
        }

        setupEditingCoordinator()
        setupContent()
        preloadContent()
        
        if let entity = entity ?? userEntity?.series {
            title = entity.name
        }
        
        let loadingDelegate = CustomLoadingDelegate(handler: { (operation: NetworkRequestOperation, loading: Bool, error: NSError?) in
            if !loading {
                self.additionalInfosLoadingView.removeFromSuperview()
                
                if let error = error {
                    self.showError(error, context: operation, completion: nil)
                }
            }
        })
        
        loadDetailedContent(loadingDelegate: loadingDelegate)
    }

    func loadDetailedContent(loadingDelegate: NetworkLoading?) {
        apiGetEntityMethod().request(loadingDelegate: loadingDelegate) { (success: Bool, entity: AnyObject?) in
            if success {
                self.hasDetailedContent = true
                if let entity = entity as? Entity {
                    self.entity = entity
                    self.userEntity?.series = entity
                }
                self.reloadContent()
            }
        }
    }

    func apiGetEntityMethod() -> API! {
        return nil
    }
    
    func apiAddEntityMethod(changes: EntityChanges) -> API! {
        return nil
    }

    func apiDeleteEntityMethod() -> API! {
        return nil
    }
    
    var userEntityListIsEditable: Bool {
        return false
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        if error.domain == APIErrorDomain && error.code == APIInvalidEntityErrorCode {
            return ErrorCenter.noEntityDetailsError
        }
        return super.messageForNetworkError(error)
    }
    
    // MARK: - Content
    
    func setupContent() {
        mainContainerView.isHidden = true
        pictureImageView.layer.cornerRadius = 12
        pictureImageView.layer.masksToBounds = true
        
        [addEntityButton, deleteButton].forEach { button in
            button?.layer.borderColor = button?.titleColor(for: .normal)?.cgColor
            button?.layer.borderWidth = 1
            button?.layer.cornerRadius = 6
            button?.layer.masksToBounds = true
        }
        
        moreInfoButtons.forEach { button in
            button.layer.borderColor = button.titleColor(for: .normal)?.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 6
            button.layer.masksToBounds = true
        }
        
        buildStackView(userContainerView, contentViews: userContentViews, hiddenViews: userContentHiddenViews + userContentShowMoreButton.superview!)
        buildStackView(mainContainerView, contentViews: mainContainersView, hiddenViews: mainContainersHiddenView)
        
        updateFieldsVisibility(with: entityListStatus)
    }
    
    func updateFieldsVisibility(with entityListStatus: EntityListStatus) {
        switch entityListStatus {
        case .unknown:
            userContainerView.isHidden = true
            topSeparatorView.isHidden = true
            addEntityContainerView.isHidden = true
            forceHideEmptyContainerView(deleteContainerView)
        case .inList:
            addEntityContainerView.isHidden = true
            if hasDetailedContent {
                deleteContainerView.isHidden = false
            }
            topSeparatorView.isHidden = false
            userContainerView.isHidden = false
        case .notInList:
            addEntityContainerView.isHidden = false
            userContainerView.isHidden = true
            topSeparatorView.isHidden = true
            if hasDetailedContent {
                deleteContainerView.isHidden = true
            }
            forceHideEmptyContainerView(deleteContainerView)
        }
    }
    
    func reloadContent() {
        preloadContent()
        loadAdditionalContent()
    }
    
    func preloadContent() {
        if let userEntity = userEntity {
            preloadContent(withUserEntity: userEntity)
        }
        else if let entity = entity {
            preloadContent(withEntity: entity)
        }
    }
    
    func preloadContent(withEntity entity: Entity) {
        mainContainerView.isHidden = false
        
        pictureImageView.setImageWithURLString(entity.pictureURL)
        titleLabel.text = entity.name
        typeLabel.text = entity.type.displayString
        statusLabel.text = entity.status.displayString
    }
    
    func preloadContent(withUserEntity entity: UserEntity) {
        preloadContent(withEntity: entity.series)
        updateUserEntityValues(entity)
    }
    
    func updateUserEntityValues(_ entity: UserEntity) {
        
    }
    
    func loadAdditionalContent() {
        if let userEntity = userEntity {
            loadAdditionalContent(withUserEntity: userEntity)
        }
        else if let entity = entity {
            loadAdditionalContent(withEntity: entity)
        }
    }
    
    func loadAdditionalContent(withEntity entity: Entity) {
        buildSectionStackView(withContainer: alternativeTitlesStackContainerView, data: [
            ("English", entity.alternativeTitles.english.joined(separator: ", ")),
            ("Synonyms", entity.alternativeTitles.synonyms.joined(separator: ", ")),
            (self.originalTitleDisplayLabel, entity.alternativeTitles.japanese.joined(separator: ", "))
            ])
        
        buildSectionStackView(withContainer: statisticsStackContainerView, data: [
            ("Score", entity.membersScore.map { String(format: "%.2f", $0) }),
            ("Ranked", entity.rank.map { "#\($0.formattedString)" }),
            ("Popularity", entity.popularityRank.map { "#\($0.formattedString)" }),
            ("Members", entity.membersCount.map { $0.formattedString }),
            ("Favorites", entity.favoritesCount.map { "\($0)" })
            ])
        
        setSynopsisAndBackground(from: entity)
        
        let relatedData: [(section: String?, items: [Any])] = entity.related.map({ ($0.section, $0.items) })
        
        relatedManagedTableView.headerNibName = "EntityRelatedTableViewHeader"
        if !relatedManagedTableView.setup(withData: relatedData,
                                                  heightForItem: { _ in EntityRelatedTableViewCell.requiredCellHeight },
                                                  selectAction: { [weak self] item in self?.userDidTapRelatedEntity(item as AnyObject) }) {
            forceHideEmptyContainerView(relatedContainerView)
        }
        
        setupMoreButton()
    }
    
    func loadAdditionalContent(withUserEntity entity: UserEntity) {
        loadAdditionalContent(withEntity: entity.series)
    }
    
    var originalTitleDisplayLabel: String {
        return "Japanese"
    }
    
    // MARK: - Pictures
    
    @IBAction func picturePressed() {
        if let pictures = allPictureURLs {
            showPictures(pictures)
        }
        else {
            apiGetPicturesMethod().request(loadingDelegate: self) { (success: Bool, pictures: [String]?) in
                self.allPictureURLs = pictures ?? []
                if success, let pictures = pictures {
                    self.showPictures(pictures)
                }
            }
        }
    }
    
    func apiGetPicturesMethod() -> API! {
        return nil
    }
    
    func showPictures(_ pictures: [String]) {
        if pictures.isEmpty {
            if let picture = (userEntity?.series ?? entity)?.pictureURL, !picture.isEmpty {
                presentPicturesController(urls: [picture])
            }
        }
        else {
            presentPicturesController(urls: pictures)
        }
    }
    
    func presentPicturesController(urls: [String]) {
        let photos = urls.map { INSPhoto(imageURL: URL(string: $0), thumbnailImageURL: nil) }
        let controller = EntityPhotosViewController(photos: photos)
        (controller.overlayView as? INSPhotosOverlayView)?.navigationItem.rightBarButtonItem = nil
        
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Add to list
    
    func additionAvailableStatusesDisplayStrings() -> [String] {
        return []
    }
    
    func entityStatus(for status: String?) -> EntityUserStatus {
        return .unknown
    }
    
    @IBAction func addToListPressed() {
        let statuses = additionAvailableStatusesDisplayStrings()
        
        let controller = ManagedPickerViewController.picker(withData: statuses, selectedIndex: nil, completion: { (save, index) in
            if save {
                let status = self.entityStatus(for: statuses[safe: index])
                self.addEntityToList(with: status)
            }
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }

    func changesForNewEntity(with status: EntityUserStatus) -> EntityChanges! {
        return nil
    }
    
    func addEntityToList(with status: EntityUserStatus) {
        Analytics.track(event: .addedEntity(analyticsEntityType))
        
        let changes = changesForNewEntity(with: status)
        apiAddEntityMethod(changes: changes!).request(loadingDelegate: self) { success in
            if success {
                self.view.makeSuccessToast {
                    SocialNetworkManager.postChanges(changes!, fromViewController: self)
                    changes?.commitChanges()
                    self.userEntity = changes?.originalEntity
                    self.userDidAddEntityToList(self.userEntity!)
                }
            }
        }
    }
    
    func userDidAddEntityToList(_ entity: UserEntity) {
        updateUserEntityValues(entity)
        
        entityListStatus = .inList
        updateFieldsVisibility(with: entityListStatus)
        
        CurrentUser.me.addEntity(entity)
    }
    
    // MARK: - Delete
    
    @IBAction func deletePressed() {
        let entityTitle = userEntity?.series.name ?? ""
        
        let alert = UIAlertController(title: nil, message: "Are you sure you want to remove \"\(entityTitle)\" from your list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
            self.deleteEntityFromList()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteEntityFromList() {
        Analytics.track(event: .deletedEntity(analyticsEntityType))
        apiDeleteEntityMethod().request(loadingDelegate: self) { success in
            if success {
                self.view.makeSuccessToast() {
                    self.closeController()
                }
                if let entity = self.userEntity {
                    CurrentUser.me.deleteEntity(entity)
                }
            }
        }
    }
    
    // MARK: - Related
    
    func userDidTapRelatedEntity(_ entity: AnyObject) {
        Analytics.track(event: .showRelated)
        if let related = entity as? RelatedEntity {
            if related.animeIdentifier != nil {
                CurrentUser.me.requireUserList(type: .anime, loadingDelegate: self) {
                    if let controller = AnimeDetailsViewController.controller(withRelatedAnime: related) {
                        self.presentDetailsController(controller)
                    }
                }
            }
            else if related.mangaIdentifier != nil {
                CurrentUser.me.requireUserList(type: .manga, loadingDelegate: self) {
                    if let controller = MangaDetailsViewController.controller(withRelatedManga: related) {
                        self.presentDetailsController(controller)
                    }
                }
            }
        }
    }
    
    func presentDetailsController(_ controller: EntityDetailsViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - More button
    
    func setupMoreButton() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "More"), style: .plain, target: self, action: #selector(self.moreButtonPressed))
        if keyboardIsVisible {
            regularRightNavigationButton = button
        }
        else {
            navigationItem.rightBarButtonItem = button
        }
    }
    
    @objc func moreButtonPressed() {
        let entity: Entity! = self.entity ?? userEntity?.series
        if let actionSheet = ManagedActionSheetViewController.actionSheet(withTitle: entity.name) {
            
            setupMoreInfosActionSheetAdditionalData(actionSheet: actionSheet)
            
            actionSheet.addAction(ManagedActionSheetAction(title: "Reviews", style: .default, action: { 
                self.showReviewsPressed()
            }))
            actionSheet.addAction(ManagedActionSheetAction(title: "Recommendations", style: .default, action: {
                self.showRecommendationsPressed()
            }))
            
            actionSheet.addAction(ManagedActionSheetAction(title: "", style: .separator, action: nil))
            
            actionSheet.addAction(ManagedActionSheetAction(title: "Share...", style: .default, action: {
                self.sharePressed()
            }))
            
            if entityListStatus == .inList {
                actionSheet.addAction(ManagedActionSheetAction(title: "Remove from my list", style: .destructive, action: { 
                    self.deletePressed()
                }))
            }
            else {
                actionSheet.addAction(ManagedActionSheetAction(title: "Add to my list", style: .done, action: { 
                    self.addToListPressed()
                }))
            }
            
            DispatchQueue.main.async {
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    func setupMoreInfosActionSheetAdditionalData(actionSheet: ManagedActionSheetViewController) {}
    
    func showReviewsPressed() {}
    func showRecommendationsPressed() {}
    
    func sharePressed() {
        let entity: Entity! = self.entity ?? userEntity?.series
        if let url = URL(string: entity.malURL) {
            let items: [Any] = [url, entity.name]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(activityViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Computed content
extension EntityDetailsViewController {
    func setSynopsisAndBackground(from entity: Entity) {
        setHTMLContent(contentText: entity.synopsis, label: synopsisLabel, containerView: synopsisContainerView)
        setHTMLContent(contentText: entity.background, label: backgroundLabel, containerView: backgroundContainerView)
    }
    
    func setHTMLContent(contentText: String?, label: UILabel, containerView: UIView) {
        var hasContent = false
        
        do {
            if let contentText = contentText {
                let content = EntityHTMLRepresentation.htmlTemplate(withContent: contentText, color: ThemeManager.currentTheme.entity.htmlDescription.color)
                if let data = content.data(using: String.Encoding.unicode, allowLossyConversion: true) {
                    let parsedContent = try NSAttributedString(data: data,
                                                               options: [.documentType: NSAttributedString.DocumentType.html,
                                                                         .characterEncoding: String.Encoding.utf8.rawValue],
                                                               documentAttributes: nil)
                    
                    label.attributedText = EntityHTMLRepresentation.colorLinks(forHTMLContent: parsedContent)
                    hasContent = true
                }
            }
        }
        catch {}
        
        if !hasContent {
            forceHideEmptyContainerView(containerView)
        }
    }
}

// MARK: - Actions
extension EntityDetailsViewController {
    @IBAction func showMorePressed() {
        self.userContentHiddenViews.forEach { $0.alpha = self.userContentIsShowingExtra ? 1 : 0 }
        UIView.animate(withDuration: 0.3, animations: {
            self.userContentHiddenViews.forEach {
                $0.isHidden = self.userContentIsShowingExtra
                $0.alpha = self.userContentIsShowingExtra ? 0 : 1
            }
            
            self.userContentIsShowingExtra = !self.userContentIsShowingExtra
            self.userContentShowMoreButton.setTitle(self.userContentIsShowingExtra ? "Less..." : "More...", for: .normal)
        })
    }
    
    func closeModalPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func closeController() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func viewOnMALPressed() {
        if let urlString = (userEntity?.series ?? entity)?.malURL {
            URL(string: urlString)?.open(in: self)
        }
    }
}

// MARK: - Editing
extension EntityDetailsViewController: KeyboardDelegate, EntityEditingCoordinatorDelegate {
    func setupNavigationBarButtonItemsForEditingMode() {
        let theme = ThemeManager.currentTheme
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelEditingPressed))
        cancelButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.global.bars.content.color], for: UIControlState())
        
        var saveButton: UIBarButtonItem! = nil
        if !editingCoordinator.hasChanges() {
            saveButton = UIBarButtonItem(title: "No change", style: .plain, target: nil, action: nil)
            saveButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.global.bars.content.color.withAlphaComponent(0.6)], for: UIControlState())
        }
        else {
            saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveEditingPressed))
            saveButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.global.activeTint.color], for: UIControlState())
        }
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func changesDidUpdate(coordinator: EntityEditingCoordinator) {
        if keyboardIsVisible {
            setupNavigationBarButtonItemsForEditingMode()
        }
    }
    
    func presentEditController(controller: UIViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func cancelEditingPressed() {
        stopEditing(saveChanges: false)
        editingCoordinator.revertAllChanges()
    }
    
    @objc func saveEditingPressed() {
        stopEditing(saveChanges: true)
        
        if editingCoordinator.hasChanges() {
            Analytics.track(event: .updatedEntity(analyticsEntityType))
            editingCoordinator.commitChanges(self)
        }
    }
}

// MARK: - Editing
extension EntityDetailsViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unconfigureKeyboard()
    }

    func animateAlongSideKeyboardAnimation(appear: Bool, height: CGFloat) {

        if baseScrollViewBottomInset == nil {
            baseScrollViewBottomInset = scrollView.contentInset.bottom
        }
        scrollView.contentInset.bottom = appear ? height : baseScrollViewBottomInset!
        
        let keyboardVisible = appear
        if keyboardVisible != keyboardIsVisible {
            keyboardIsVisible = keyboardVisible
            if keyboardVisible {
                scrollView.setContentOffset(CGPoint(x: 0, y: userContainerView.frame.minY - 12 - scrollView.trueContentInset.top), animated: false)
            }
            
            UIView.performWithoutAnimation {
                self.setupButtons(forKeyboardVisibility: keyboardVisible)
            }
        }
    }
    
    func setupButtons(forKeyboardVisibility visible: Bool) {
        if visible {
            regularLeftNavigationButton = navigationItem.leftBarButtonItem
            regularRightNavigationButton = navigationItem.rightBarButtonItem
            
            setupNavigationBarButtonItemsForEditingMode()
        }
        else {
            navigationItem.leftBarButtonItem = regularLeftNavigationButton
            navigationItem.rightBarButtonItem = regularRightNavigationButton
        }
    }
    
    func stopEditing(saveChanges save: Bool) {
        view.endEditing(true)
    }
}

// MARK: - StackView
extension EntityDetailsViewController {
    func buildStackView(_ containerView: UIView, contentViews: [UIView], hiddenViews: [UIView]) {
        var arrangedViewContainer: UIView! = nil
        
        let stackView = UIStackView(arrangedSubviews: contentViews)
        stackView.axis = .vertical
        arrangedViewContainer = stackView
        
        arrangedViewContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubviewPinnedToEdges(arrangedViewContainer)
        
        hiddenViews.forEach { $0.isHidden = true }
    }
    
    func buildSectionStackView(withContainer containerView: UIView, data: [(String, String?)]) {
        var contentViews: [UIView] = []

        for (title, content) in data {
            if let content = content, !content.isEmpty {
                let row = EntityDetailsInformationRowView.build(withTitle: title, content: content)
                contentViews.append(row)
            }
        }
        
        if contentViews.isEmpty {
            if let superview = containerView.superview {
                forceHideEmptyContainerView(superview)
            }
        }
        else {
            buildStackView(containerView, contentViews: contentViews, hiddenViews: [])
        }
    }
    
    func forceHideEmptyContainerView(_ containerView: UIView) {
        if let index = mainContainersHiddenView.index(of: containerView) {
            mainContainersHiddenView.remove(at: index)
        }
    }
}

class EntityPhotosViewController: INSPhotosViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme.global.statusBar.style
    }
}


