//
//  EntityListSearchViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 10/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntityListSearchViewController: RootViewController {
    var tableView: UITableView! {
        return tableViewController?.tableView
    }
    
    struct SectionInfos {
        var title: String
        var expanded: Bool
        var items: [AnyObject]
        
        init(title: String, items: [AnyObject], expanded: Bool) {
            self.title = title
            self.items = items
            self.expanded = expanded
        }
        
        var displayedItems: Int {
            return expanded ? items.count : 0
        }
    }
    
    var filteredList: SectionInfos = SectionInfos(title: "", items: [], expanded: true)
    var fuzzyMatchList: SectionInfos = SectionInfos(title: "", items: [], expanded: true)
    var searchResults: SectionInfos = SectionInfos(title: "", items: [], expanded: true)
    
    func sectionInfos(for index: Int) -> SectionInfos {
        return [filteredList, fuzzyMatchList, searchResults][index]
    }
    
    private var unfilteredSearchIndex_ : [Int: Entity]?
    var unfilteredSearchResults: [Entity] = []
    
    func invalidateUnfilteredSearchResultIndex() {
        unfilteredSearchIndex_ = nil
    }
    
    func entityIsInUnfilteredSearchResults(_ entity: Entity) -> Bool {
        if let unfilteredSearchIndex = unfilteredSearchIndex_ {
            return unfilteredSearchIndex[entity.identifier] != nil
        }
        else {
            var index = [Int: Entity]()
            unfilteredSearchResults.forEach { item in
                index[item.identifier] = item
            }
            unfilteredSearchIndex_ = index
            return index[entity.identifier] != nil
        }
    }
    
    var tableViewController: UITableViewController!
    var currentSearchText: String = ""
    var currentSearchRequest: NetworkRequestOperation?
    var currentSearchPage: Int = 1
    var searchFooterView: EntitySearchFooterView!
    
    var attachedEntityListController: EntityListViewController!
    
    var entityName: String {
        return ""
    }
    
    var analyticsEntityType: Analytics.EntityType! {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset.top = attachedEntityListController.listDisplayProxy?.scrollView?.contentInset.top ?? 0
        tableView.contentInset.bottom = attachedEntityListController.tabBarController?.tabBar.bounds.height ?? 0
        
        filteredList.title = "In my \(entityName) list"
        fuzzyMatchList.title = "Possible matches in my list"
        searchResults.title = "Not in my list"
        
        let expandedStates = Settings.searchSectionState
        filteredList.expanded = expandedStates[0] ?? true
        fuzzyMatchList.expanded = expandedStates[1] ?? true
        searchResults.expanded = expandedStates[2] ?? true
        
        searchFooterView = EntitySearchFooterView.footer(entityName: entityName, delegate: self)
        tableView.tableFooterView = searchFooterView
        
        tableView.backgroundColor = .clear
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.separatorColor = theme.separators.entityList.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UITableViewController" {
            tableViewController = segue.destination as? UITableViewController
            
            tableViewController.tableView.register(UINib(nibName: "EntityTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "EntityTableViewHeader")
            tableViewController.tableView.delegate = self
            tableViewController.tableView.dataSource = self
            tableViewController.tableView.keyboardDismissMode = .onDrag
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.contentInset.top = self.attachedEntityListController.listDisplayProxy?.scrollView?.contentInset.top ?? 0
        }, completion: { _ in
            self.tableView.contentInset.top = self.attachedEntityListController.listDisplayProxy?.scrollView?.contentInset.top ?? 0
            self.tableView.reloadData()
        })
    }
    
    func reloadData() {
        tableView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    var cellIdentifier: String {
        return ""
    }
    
    var searchCellIdentifier: String {
        return ""
    }
    
    var visibleCells: [EntityCell] {
        return tableViewController?.tableView?.visibleCells.compactMap { $0 as? EntityCell } ?? []
    }
    
    // MARK: - Actions
    
    private func isInMyList(entity: Entity) -> Bool {
        if let anime = entity as? Anime {
            return CurrentUser.me.cachedAnimeList()?.find(by: anime.identifier) != nil
        }
        else if let manga = entity as? Manga {
            return CurrentUser.me.cachedMangaList()?.find(by: manga.identifier) != nil
        }
        return false
    }
    
    private func entityPresentingContext(for entity: Entity) -> EntityPresentingContext {
        return isInMyList(entity: entity) ? .myList : .other
    }

    func fillListEntityCell(_ cell: EntityTableViewCell, item: UserEntity?) {
        if let item = item {
            let metadata: EntityCellMetadata? = currentSearchText.isEmpty ? nil : EntityCellMetadata(highlightedText: currentSearchText, wantsFullStatus: true, style: .tableViewDefault)
            cell.fill(withUserEntity: item, metadata: metadata)
        }
    }
    
    func sectionPressed(_ section: Int) {
        if section == 0 {
            filteredList.expanded = !filteredList.expanded
        }
        else if section == 1 {
            fuzzyMatchList.expanded = !fuzzyMatchList.expanded
        }
        else {
            searchResults.expanded = !searchResults.expanded
        }
        
        tableView.reloadSections(IndexSet(integer: section), with: .fade)
        Settings.searchSectionState = [0: filteredList.expanded, 1: fuzzyMatchList.expanded, 2: searchResults.expanded]
    }
    
    // MARK: - Content
    
    func apiSearchEntityMethod(terms: String, page: Int? = nil) -> API! {
        return nil
    }
    
    var requiredListKind: EntityKind? {
        return nil
    }
    
    func entityIsAlreadyInList(_ entity: Entity) -> Bool {
        return false
    }
    
    func shouldFilterEntity(_ entity: Entity) -> Bool {
        return Settings.filterRatedX && entity.classification == EntityRating.hentai.shortSymbol
    }
    
    func filterEntities(_ entities: [Entity]) -> [Entity] {
        return entities.filter { !entityIsAlreadyInList($0) && !shouldFilterEntity($0) }
    }
    
    func shouldIncludeEntityInListResult(_ entity: Entity) -> Bool {
        return entityIsInUnfilteredSearchResults(entity) && !shouldFilterEntity(entity)
    }
    
    private func requireList(completion: @escaping () -> Void) {
        if let kind = requiredListKind {
            CurrentUser.me.requireUserList(type: kind, loadingDelegate: self, completion: completion)
        }
        else {
            completion()
        }
    }
    
    func searchEntity(searchTerms: String) {
        requireList {
            self.currentSearchRequest = self.apiSearchEntityMethod(terms: searchTerms, page: self.currentSearchPage).request(loadingDelegate: self.searchFooterView) { (success: Bool, entities: [Entity]?) in
                if let entities = entities, success {
                    if entities.count > 0 {
                        self.searchFooterView.showNextPageButton()
                    }
                    let newEntities = self.filterEntities(entities)
                    if self.currentSearchPage > 1 {
                        self.searchResults.items.append(contentsOf: newEntities as [AnyObject])
                        self.unfilteredSearchResults.append(contentsOf: entities)
                    }
                    else {
                        self.searchResults.items = newEntities
                        self.unfilteredSearchResults = entities
                    }
                    
                    self.invalidateUnfilteredSearchResultIndex()
                    self.updateFilteredList()
                    
                    if self.searchResults.items.isEmpty {
                        self.searchFooterView.showNoResultsLabel()
                    }
                    self.reloadData()
                }
            }
        }
    }
    
    func startNewSearch(searchTerms: String) {
        if let request = currentSearchRequest {
            request.cancel()
        }
        
        searchResults.items = []
        fuzzyMatchList.items = []
        unfilteredSearchResults = []
        invalidateUnfilteredSearchResultIndex()
        
        if searchTerms.count > 2 {
            currentSearchPage = 1
            searchEntity(searchTerms: searchTerms)
        }
        else {
            searchFooterView.showCharacterLimitLabel()
        }
        
        Analytics.track(event: .search(analyticsEntityType))
    }
}

extension EntityListSearchViewController : EntitySearchFooterDelegate {
    func nextPagePressed() {
        currentSearchPage += 1
        searchEntity(searchTerms: currentSearchText)
    }
}

extension EntityListSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchBar.text ?? ""

        guard search != currentSearchText else { return }
        
        currentSearchText = search
        updateFilteredList()
        
        startNewSearch(searchTerms: currentSearchText)
        reloadData()
    }
    
    func updateFilteredList() {
        if currentSearchText.isEmpty {
            filteredList.items = []
            fuzzyMatchList.items = []
        }
        else {
            filteredList.items = attachedEntityListController.items
                .filter({ item in
                    item.series.name.range(of: currentSearchText, options: .caseInsensitive) != nil
                })
                .sorted(by: { a, b in
                    a.sortingStatus != b.sortingStatus ? (a.sortingStatus.rawValue < b.sortingStatus.rawValue) : (a.series.name.lowercased() < b.series.name.lowercased())
                })
            
            fuzzyMatchList.items = attachedEntityListController.items
                .filter({ item in
                    shouldIncludeEntityInListResult(item.series) && item.series.name.range(of: currentSearchText, options: .caseInsensitive) == nil
                })
                .sorted(by: { a, b in
                    a.sortingStatus != b.sortingStatus ? (a.sortingStatus.rawValue < b.sortingStatus.rawValue) : (a.series.name.lowercased() < b.series.name.lowercased())
                })
        }
    }
    
    func forceReloadCurrentState() {
        updateFilteredList()
        searchResults.items = filterEntities(searchResults.items as! [Entity])
        reloadData()
    }
}

// MARK: - TableView Delegate
extension EntityListSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionInfos(for: section).displayedItems
    }
    
    func sectionIsInList(_ section: Int) -> Bool {
        return section == 0 || section == 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sectionIsInList(indexPath.section) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EntityTableViewCell
            
            cell.longPressDelegate = self
            fillListEntityCell(cell, item: sectionInfos(for: indexPath.section).items[indexPath.row] as? UserEntity)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: searchCellIdentifier, for: indexPath) as! EntitySearchTableViewCell
            
            cell.longPressDelegate = self
            cell.fill(with: searchResults.items[indexPath.row] as! Entity)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionIsInList(indexPath.section) ? 112 : 84
    }
    
    private func getEntity(at indexPath: IndexPath) -> Entity? {
        if sectionIsInList(indexPath.section) {
            return (sectionInfos(for: indexPath.section).items[indexPath.row] as? UserEntity)?.series
        }
        else {
            return searchResults.items[indexPath.row] as? Entity
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let entity = getEntity(at: indexPath) {
            DispatchQueue.main.async {
                self.attachedEntityListController.showEntityDetails(entity: entity, context: self.entityPresentingContext(for: entity))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EntityTableViewHeader") as? EntityTableViewHeader {
            let sectionInfos = self.sectionInfos(for: section)
            
            let rightText = "\(sectionInfos.items.count)"
            header.fill(withSection: section, title: sectionInfos.title, rightText: rightText, context: .search(expanded: sectionInfos.expanded), pressedAction: { [weak self] section in
                self?.sectionPressed(section)
                })
            
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Database.shared.entitiesTableViewHeaderHeight
    }
}

extension EntityListSearchViewController: EditableEntityCellDelegate, EntityCellLongPressDelegate {
    func didLongPressCell(_ cell: EntityOwnerCell) {
        attachedEntityListController.showEntityDetails(entity: cell.entity, alternativeAction: true, context: self.entityPresentingContext(for: cell.entity))
    }
    
    func canEditCell(_ cell: EditableEntityCell) -> Bool {
        return attachedEntityListController.canEditCell(cell)
    }
    
    func lockEditingToCell(_ cell: EditableEntityCell) -> Bool {
        return attachedEntityListController.lockEditingToCell(cell)
    }
    
    func unlockEditing() {
        attachedEntityListController.unlockEditing()
    }
    
    func shouldShowScorePickerForUpdate(cell: EditableEntityCell, currentScore: Int?, completion: @escaping (Int?) -> Void) {
        attachedEntityListController.shouldShowScorePickerForUpdate(cell: cell, currentScore: currentScore, completion: completion)
    }
}
