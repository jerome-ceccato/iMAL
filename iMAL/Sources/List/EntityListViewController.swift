//
//  EntityListViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityListViewController: RootViewController {
    @IBOutlet var listContainerView: UIView!
    var listDisplayProxy: ListDisplayProxy?
    
    var items: [UserEntity] = []
    var sortedItems: [SectionInfos] = []
    
    var isReloading: Bool = false
    var shouldReloadAfterEditEnds: Bool = false
    var editLockedCell: EditableEntityCell?
    
    var editable: Bool {
        return false
    }
    
    var editingLocked: Bool {
        return editLockedCell != nil
    }
    
    var searchController: UISearchController!
    var searchResultsController: EntityListSearchViewController?
    @IBOutlet var searchBarButton: UIBarButtonItem?
    @IBOutlet var sortBarButton: UIBarButtonItem?
    
    var pinchToCollapseGestureRecognizer: UIPinchGestureRecognizer?
    
    var previousSortingStatus = EntityListSorting()
    var currentSortingStatus = EntityListSorting()
    
    struct SectionInfos {
        var title: String
        var metadata: Metadata
        var items: [UserEntity]
        
        init(title: String, items: [UserEntity], metadata: Metadata) {
            self.title = title
            self.items = items
            self.metadata = metadata
        }
        
        struct Metadata {
            var expanded: Bool = false
            
            init(expanded: Bool = false) {
                self.expanded = expanded
            }
        }
    }
    
    var cellType: EntityListCellType {
        return .undefined
    }
    
    var listStyle: ListDisplayStyle {
        return .tableViewDefault
    }
    
    var entityPresentingContext: EntityPresentingContext {
        return editable ? .myList : .other
    }

    override func viewDidLoad() {
        listDisplayProxy = ListDisplayProxy(owner: self)
        
        super.viewDidLoad()

        if !loadCachedList() {
            remoteReloadListIfNeeded()
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            (self.listDisplayProxy?.footerView as? UILabel)?.textColor = theme.misc.listFooterText.color
            self.listDisplayProxy?.tableViewController?.tableView?.separatorColor = theme.separators.entityList.color
            self.listDisplayProxy?.scrollView?.indicatorStyle = theme.global.scrollIndicators.style
            self.listDisplayProxy?.reloadData()
            if let controller = self.searchController {
                self.themeSearchController(controller)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listDisplayProxy?.didLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        listDisplayProxy?.willTransition(to: size, with: coordinator)
    }
    
    func didLoadListCollectionView() {
        setupGestures()
    }
    
    func loadCachedList() -> Bool {
        return false
    }
    
    deinit {
        NotificationCenter.unregister(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadContent()
    }
    
    @objc func remoteReloadListIfNeeded() {
        if !isReloading {
            isReloading = true
            remoteReloadList {
                self.isReloading = false
                self.listDisplayProxy?.refreshControlEndRefreshing()
            }
        }
    }
    
    @objc func remoteReloadList(_ completion: @escaping () -> Void) {
    }
    
    func emptyListReceived() {
    }
    
    func reloadContent() {
        sortedItems = buildSortingTableDefault()
        listDisplayProxy?.reloadData()
        searchResultsController?.tableView?.reloadData()
        setupFooterLabel()
    }

    var areCellsGloballyLocked: Bool {
        return false
    }

    // MARK: - Footer
    
    func setupFooterLabel() {
        if items.isEmpty {
            listDisplayProxy?.footerView = nil
            return
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: AppDelegate.shared.viewPortSize.width, height: 50))
        label.autoresizingMask = .flexibleWidth
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = ThemeManager.currentTheme.misc.listFooterText.color
        label.textAlignment = .center
        label.numberOfLines = 2
        
        if listDisplayProxy?.footerView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.startAnimating()
            listDisplayProxy?.footerView = indicator
        }
        
        DispatchQueue.global().async {
            let content = self.footerContentString()
            DispatchQueue.main.async {
                label.text = content
                self.listDisplayProxy?.footerView = label
            }
        }
    }
    
    func footerContentString() -> String {
        return ""
    }

    // MARK: - Actions

    func fill(cell: EntityCell, withEntity entity: UserEntity) {
        cell.fill(withUserEntity: entity, metadata: EntityCellMetadata(highlightedText: nil, wantsFullStatus: currentSortingStatus.grouping != .status, style: listDisplayProxy?.currentStyle ?? .tableViewDefault))
    }
    
    func sectionPressed(_ section: Int) {
        if sortedItems[safe: section] != nil {
            listDisplayProxy?.toggleSectionsVisible(sections: [section])
        }
    }
    
    func currentSectionsExpandedState() -> [EntityUserStatus: Bool] {
        var ret = [EntityUserStatus: Bool] ()
        sortedItems.forEach { item in
            if let status = item.items.first?.sortingStatus {
                ret[status] = item.metadata.expanded
            }
        }
        return ret
    }
    
    func setCurrentSectionsExpandedState(_ state: [EntityUserStatus: Bool]) {
        if currentSortingStatus.grouping == .status {
            sortedItems.enumerated().forEach { (index, item) in
                let expanded = state[item.items.first?.sortingStatus ?? .unknown] ?? false
                sortedItems[index].metadata.expanded = expanded
            }
            listDisplayProxy?.reloadData()
        }
    }
    
    func animateNavigationBarUpdate(duration: TimeInterval = 0.2, update: () -> Void) {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = duration
        fadeTextAnimation.type = kCATransitionFade
        
        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        update()
    }
    
    @IBAction func startSearch() {
        animateNavigationBarUpdate {
            // The cancel button is not displayed on iPad, so we add it ourselves
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissSearchController))
            navigationItem.rightBarButtonItem = UIDevice.current.isiPad() ? cancelButton : nil
            navigationItem.leftBarButtonItem = nil
            
            navigationItem.titleView = searchController.searchBar
            
            searchController.searchBar.becomeFirstResponder()
        }
    }

    // MARK: - Search

    func instanciateSearchController() -> EntityListSearchViewController? {
        return storyboard?.instantiateViewController(withIdentifier: "EntityListSearchViewController") as? EntityListSearchViewController
    }
    
    func buildSearchController() {
        let resultsController = instanciateSearchController()
        resultsController?.attachedEntityListController = self
        
        let controller = UISearchController(searchResultsController: resultsController)
        controller.dimsBackgroundDuringPresentation = true
        controller.hidesNavigationBarDuringPresentation = false
        
        themeSearchController(controller)
        
        controller.delegate = self
        controller.searchResultsUpdater = resultsController
        
        definesPresentationContext = true
        
        searchResultsController = resultsController
        searchController = controller
        
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
            
            controller.searchBar.showsCancelButton = false
            controller.hidesNavigationBarDuringPresentation = true
            navigationItem.searchController = searchController
            
            searchBarButton = nil
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func themeSearchController(_ controller: UISearchController) {
        let theme = ThemeManager.currentTheme.global
        controller.searchBar.tintColor = theme.bars.content.color
        controller.searchBar.backgroundColor = UIColor.clear
        if #available(iOS 11, *) {} else {
            controller.searchBar.setSearchFieldBackgroundImage(withColor: theme.viewBackground.color)
            controller.searchBar.setSearchFieldTextColor(theme.bars.title.color)
            controller.searchBar.showsCancelButton = UIDevice.current.isiPad() ? false : true
        }
        controller.searchBar.keyboardAppearance = theme.keyboardStyle.style
    }

    // MARK: - Sorting
    
    func buildSortingTableDefault() -> [SectionInfos] {
        let previousItems: [SectionInfos]? = previousSortingStatus == currentSortingStatus ? sortedItems : nil
        previousSortingStatus = currentSortingStatus
        return buildSortingTable(currentSortingStatus, previousItems: previousItems)
    }
    
    func buildSortingTable(_ options: EntityListSorting, previousItems: [SectionInfos]?) -> [SectionInfos] {
        var table: [String: (identifier: AnyObject, items: [UserEntity])] = [:]
        
        for item in items {
            options.sectionInfos(item).forEach { infos in
                if table[infos.title] != nil {
                    table[infos.title]!.items.append(item)
                }
                else {
                    table[infos.title] = (identifier: infos.identifier, items: [item])
                }
            }
        }
        
        return table
            .map { (key, value) in (title: key, identifier: value.identifier, items: value.items) }
            .sorted { (a, b) in options.sortSections(a.identifier, b.identifier) }
            .map { (title, identifier, items) in SectionInfos(title: title, items: items.sorted(by: options.sortItems), metadata: options.metadata(for: title, identifier: identifier, list: self, previousItems: previousItems)) }
    }
    
    func storedStatusSectionState(for section: String) -> Bool? {
        return nil
    }
    
    func animateSortButtonChanges(appear: Bool, context: AnyObject? = nil) {
        animateNavigationBarUpdate(duration: 0.1) {
            if appear {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .plain, target: nil, action: nil)
            }
            else {
                navigationItem.rightBarButtonItem = context as? UIBarButtonItem
            }
        }
    }
    
    @IBAction func sortMainButtonPressed() {
        let rightBarButton = navigationItem.rightBarButtonItem
        animateSortButtonChanges(appear: true)
        EntityListSortViewController.presentControllerFromController(self, selectedOption: currentSortingStatus) {
            self.animateSortButtonChanges(appear: false, context: rightBarButton)
        }
    }
    
    func reload(withNewSortingOption option: EntityListSorting) {
        currentSortingStatus = option
        reloadContent()
        
        if let listDisplay = listDisplayProxy, let scrollView = listDisplay.scrollView {
            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.trueContentInset.top)
        }
    }
}

// MARK: - SortingOptions
extension EntityListSorting {
    func sectionInfos(_ item: UserEntity) -> [SectionInfos] {
        switch grouping {
        case .status:
            return [SectionInfos(identifier: item.sortingStatus.rawValue as AnyObject, title: item.sortingStatusDisplayString)]
        case .score:
            return [SectionInfos(identifier: item.score as AnyObject, title: item.score.scoreDisplayString.isEmpty ? "No Score" : item.score.scoreDisplayString)]
        case .alphabetically:
            let firstLetter = String(item.series.name[..<item.series.name.index(item.series.name.startIndex, offsetBy: 1)]).uppercased()
            let title = firstLetter.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil ? firstLetter : "#"
            return [SectionInfos(identifier: title as AnyObject, title: title)]
        case .tags:
            let tags: [SectionInfos] = item.tags.compactMap { tag in
                let purgedTag = tag.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                return purgedTag.isEmpty ? nil : SectionInfos(identifier: purgedTag as AnyObject, title: purgedTag)
            }
            return tags.isEmpty ? [SectionInfos(identifier: "[No Tag]" as AnyObject, title: "[No Tag]")] : tags
        }
    }
    
    func sortSections(_ a: AnyObject, _ b: AnyObject) -> Bool {
        switch grouping {
        case .status:
            return (a as! Int) < (b as! Int)
        case .score:
            return (a as! Int) > (b as! Int)
        case .alphabetically, .tags:
            return (a as! String).compareSectionIndex(with: b as! String)
        }
    }
    
    func sortItems(_ a: UserEntity, _ b: UserEntity) -> Bool {
        switch sorting {
        case .alphabetically:
            return a.series.name.lowercased() < b.series.name.lowercased()
        case .lastUpdatedFirst:
            return a.lastUpdated > b.lastUpdated
        case .score:
            return a.score > b.score
        }
    }
    
    func metadata(for section: String, identifier: AnyObject, list: EntityListViewController, previousItems: [EntityListViewController.SectionInfos]?) -> EntityListViewController.SectionInfos.Metadata {
        if let sectionInfos = previousItems?.find({ $0.title == section }) {
            return sectionInfos.metadata
        }
        
        switch grouping {
        case .status:
            if let expanded = list.storedStatusSectionState(for: section) {
                return EntityListViewController.SectionInfos.Metadata(expanded: expanded)
            }
            return EntityListViewController.SectionInfos.Metadata()
        default:
            return EntityListViewController.SectionInfos.Metadata(expanded: true)
        }
    }
}

// MARK: - Search
extension EntityListViewController: UISearchControllerDelegate {
    @objc func dismissSearchController() {
        searchController.isActive = false
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        listDisplayProxy?.scrollView?.scrollsToTop = false
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        listDisplayProxy?.scrollView?.scrollsToTop = true
        if #available(iOS 11, *) {} else {
            animateNavigationBarUpdate {
                navigationItem.leftBarButtonItem = sortBarButton
                navigationItem.rightBarButtonItem = searchBarButton
                navigationItem.titleView = nil
            }
        }
    }
}

// MARK: - Updating
extension EntityListViewController {
    func expectedIndexPath(for entity: UserEntity, inSortedItems sItems: [SectionInfos]? = nil) -> IndexPath? {
        let sortedItems = sItems ?? self.sortedItems
        
        for (section, sectionInfos) in sortedItems.enumerated() {
            if sectionInfos.metadata.expanded {
                for (row, item) in sectionInfos.items.enumerated() {
                    if item.series.identifier == entity.series.identifier {
                        return IndexPath(row: row, section: section)
                    }
                }
            }
        }
        return nil
    }
    
    func updateEntityAnimated(_ entity: UserEntity) {
        if currentSortingStatus.wantsSoftReloadOnUpdate {
            sortedItems = buildSortingTableDefault()
            listDisplayProxy?.reloadData()
        }
        else {
            let currentIndexPath = expectedIndexPath(for: entity)
            let currentNumberOfSections = sortedItems.count
            let newSortedItems = buildSortingTableDefault()
            let newIndexPath = expectedIndexPath(for: entity, inSortedItems: newSortedItems)
            let newNumberOfSections = newSortedItems.count
            
            let hasSameSections = currentNumberOfSections == newNumberOfSections
            if hasSameSections && (currentIndexPath != nil || newIndexPath != nil) {
                sortedItems = newSortedItems
                
                if let currentIndexPath = currentIndexPath, let newIndexPath = newIndexPath {
                    if currentIndexPath == newIndexPath {
                        listDisplayProxy?.reloadCells(at: [newIndexPath], animated: false)
                    }
                    else {
                        if let cell = listDisplayProxy?.visibleCellWithIndexPath(currentIndexPath) {
                            fill(cell: cell, withEntity: entity)
                        }
                        listDisplayProxy?.moveCell(at: currentIndexPath, to: newIndexPath)
                    }
                }
                else if let currentIndexPath = currentIndexPath {
                    listDisplayProxy?.deleteCells(at: [currentIndexPath], animated: true)
                }
                else if let newIndexPath = newIndexPath {
                    listDisplayProxy?.insertCells(at: [newIndexPath], animated: true)
                }
                
                for (index, section) in sortedItems.enumerated() {
                    listDisplayProxy?.updateHeaderTitle("\(section.items.count)", forSection: index)
                }
            }
            else {
                sortedItems = newSortedItems
                listDisplayProxy?.reloadData()
            }
        }
        
        searchResultsController?.tableView?.reloadData()
        setupFooterLabel()
    }
}

extension EntityListViewController: EditableEntityCellDelegate, EntityCellLongPressDelegate {
    func canEditCell(_ cell: EditableEntityCell) -> Bool {
        if areCellsGloballyLocked {
            return false
        }
        
        return editLockedCell == nil || cell === editLockedCell
    }
    
    func lockEditingToCell(_ cell: EditableEntityCell) -> Bool {
        if editLockedCell != nil {
            return false
        }
        editLockedCell = cell
        updateVisibleCellEditingStatus()
        return true
    }
    
    func unlockEditing() {
        editLockedCell = nil
        updateVisibleCellEditingStatus()
    }
    
    func updateVisibleCellEditingStatus() {
        updateEditingStatusForCells(listDisplayProxy?.visibleCells)
        updateEditingStatusForCells(searchResultsController?.visibleCells)
    }
    
    private func updateEditingStatusForCells(_ cells: [EntityCell]?) {
        if let cells = cells {
            for cell in cells {
                if let editableCell = cell as? EditableEntityCell {
                    editableCell.updateEditingStatus()
                }
            }
        }
    }
    
    func didLongPressCell(_ cell: EntityOwnerCell) {
        showEntityDetails(entity: cell.entity, alternativeAction: true, context: entityPresentingContext)
    }
    
    func shouldShowScorePickerForUpdate(cell: EditableEntityCell, currentScore: Int?, completion: @escaping (Int?) -> Void) {
        let scores = Int.scoresDisplayStrings().map { $0.isEmpty ? "None" : $0 }
        
        let controller = ManagedPickerViewController.picker(withData: scores, selectedIndex: currentScore, completion: { (save, index) in
            completion(save ? index : nil)
        })
        
        if let controller = controller {
            controller.removeCancelButton()
            present(controller, animated: true, completion: nil)
        }
        else {
            completion(nil)
        }
    }
}

// MARK: - Gestures
extension EntityListViewController: UIGestureRecognizerDelegate {
    func setupGestures() {
        guard pinchToCollapseGestureRecognizer == nil else {
            return
        }
        
        pinchToCollapseGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.userDidPinchView(_:)))
        pinchToCollapseGestureRecognizer!.delegate = self
        view.addGestureRecognizer(pinchToCollapseGestureRecognizer!)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pinchToCollapseGestureRecognizer {
            return Settings.pinchToCollapseEnabled
        }
        return true
    }
    
    @objc func userDidPinchView(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches == 2 && recognizer.scale < 0.7 {
            let sections = NSMutableIndexSet()
            
            for index in 0 ..< sortedItems.count {
                if sortedItems[index].metadata.expanded {
                    sections.add(index)
                }
            }
            
            if sections.count > 0 {
                listDisplayProxy?.toggleSectionsVisible(sections: sections as IndexSet)
            }
            
            recognizer.isEnabled = false
            recognizer.isEnabled = true
        }
    }
}
