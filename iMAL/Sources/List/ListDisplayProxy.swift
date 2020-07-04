//
//  ListDisplayProxy.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

enum EntityListCellType {
    case undefined
    
    case anime
    case editableAnime
    case friendAnime
    
    case manga
    case editableManga
    case friendManga
}

enum ListDisplayStyle: Int {
    case tableViewDefault = 0
    case collectionViewDefault = 1
    case collectionViewSmall = 2
    case collectionViewMinimalistic = 3
}

enum ListDisplayKind: Int {
    case tableView = 0
    case collectionView = 1
}

extension ListDisplayStyle {
    var kind: ListDisplayKind {
        switch self {
        case .tableViewDefault:
            return .tableView
        case .collectionViewDefault, .collectionViewSmall, .collectionViewMinimalistic:
            return .collectionView
        }
    }

    var displayString: String {
        switch self {
        case .tableViewDefault:
            return "Default List"
        case .collectionViewDefault:
            return "Large Cards"
        case .collectionViewSmall:
            return "Small Cards"
        case .collectionViewMinimalistic:
            return "Minimalistic Cards"
        }
    }
    
    static var availableStylesDisplayStrings: [String] {
        let options: [ListDisplayStyle] = [.tableViewDefault, .collectionViewDefault, .collectionViewSmall, .collectionViewMinimalistic]
        return options.map { $0.displayString }
    }
}

class ListDisplayProxy: NSObject {
    weak var owner: EntityListViewController!
    
    var currentStyle = Settings.listsStyle

    var tableViewController: UITableViewController?

    var collectionViewController: UICollectionViewController?
    var collectionViewRefreshControl: UIRefreshControl?
    
    convenience init(owner: EntityListViewController) {
        self.init()
        self.owner = owner
        self.currentStyle = owner.listStyle
        
        handleListDisplayStyleChangedNotification(self) { [weak self] in
            self?.rebuild()
        }
        
        setup()
    }
    
    private func setup() {
        switch currentStyle.kind {
        case .tableView:
            buildTableViewController()
        case .collectionView:
            buildCollectionViewController()
        }
        
        DispatchQueue.main.async {
            self.owner.didLoadListCollectionView()
        }
    }
    
    func rebuild() {
        let newStyle = owner.listStyle
        
        if self.currentStyle != newStyle {
            self.currentStyle = owner.listStyle
            [tableViewController as UIViewController?, collectionViewController as UIViewController?].forEach { controller in
                if let controller = controller {
                    controller.willMove(toParentViewController: nil)
                    controller.view.removeFromSuperview()
                    controller.removeFromParentViewController()
                }
            }
            tableViewController = nil
            collectionViewController = nil
            collectionViewRefreshControl = nil
            
            setup()
            
            tableViewController?.tableView?.reloadData()
            collectionViewController?.collectionView?.reloadData()
        }
    }
    
    func didLayout() {
    }
    
    func willTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        switch currentStyle.kind {
        case .collectionView:
            collectionViewController?.collectionView?.collectionViewLayout.invalidateLayout()
            
            coordinator.animate(alongsideTransition: { _ in
                self.collectionViewController?.collectionView?.collectionViewLayout.invalidateLayout()
            }, completion: nil)
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.unregister(self)
    }
}

// MARK: - Notifications
extension ListDisplayProxy {
    static let listDisplayStyleChangedNotificationName = "imal-lists-changed-notification"
    
    static func broadcastListDisplayStyleChangedNotification() {
        Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: listDisplayStyleChangedNotificationName), object: nil)
    }
    
    func handleListDisplayStyleChangedNotification(_ object: AnyObject, update: @escaping () -> Void) {
        NotificationCenter.register(object, ListDisplayProxy.listDisplayStyleChangedNotificationName, block: { notif in
            update()
        })
    }
}

// MARK: - Building the controllers
private extension ListDisplayProxy {
    func collectionStoryboardIdentifier() -> String {
        switch owner.cellType {
        case .anime, .editableAnime, .friendAnime:
            return "AnimeCollectionControllers"
        case .manga, .editableManga, .friendManga:
            return "MangaCollectionControllers"
        default:
            abort()
        }
    }
    
    // MARK: - TableView
    
    func buildTableViewController() {
        if let controller = UIStoryboard(name: collectionStoryboardIdentifier(), bundle: nil).instantiateViewController(withIdentifier: tableViewControllerStoryboardIdentifier()) as? UITableViewController {
            controller.view.translatesAutoresizingMaskIntoConstraints = false

            owner.addChildViewController(controller)
            owner.listContainerView.addSubviewPinnedToEdges(controller.view)
            controller.didMove(toParentViewController: owner)
            
            setupTableViewController(controller)
        }
    }
    
    func tableViewControllerStoryboardIdentifier() -> String {
        switch owner.cellType {
        case .anime, .editableAnime, .friendAnime:
            return "AnimeDefaultTableViewController"
        case .manga, .editableManga, .friendManga:
            return "MangaDefaultTableViewController"
        default:
            abort()
        }
    }
    
    func setupTableViewController(_ controller: UITableViewController) {
        tableViewController = controller
        
        let theme = ThemeManager.currentTheme
        controller.tableView?.backgroundColor = .clear
        controller.tableView?.separatorColor = theme.separators.entityList.color
        controller.tableView?.indicatorStyle = theme.global.scrollIndicators.style

        controller.tableView.register(UINib(nibName: "EntityTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "EntityTableViewHeader")
        controller.tableView.delegate = self
        controller.tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        controller.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(owner, action: #selector(owner.remoteReloadListIfNeeded), for: .valueChanged)
        controller.tableView?.addSubview(refreshControl)
    }
    
    // MARK: - CollectionView
    
    func buildCollectionViewController() {
        if let controller = UIStoryboard(name: collectionStoryboardIdentifier(), bundle: nil).instantiateViewController(withIdentifier: collectionViewControllerStoryboardIdentifier()) as? UICollectionViewController {
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            owner.addChildViewController(controller)
            owner.listContainerView.addSubviewPinnedToEdges(controller.view)
            controller.didMove(toParentViewController: owner)
            
            setupCollectionViewController(controller)
        }
    }
    
    func collectionViewControllerStoryboardIdentifier() -> String {
        switch owner.cellType {
        case .anime, .editableAnime, .friendAnime:
            return "AnimeDefaultCollectionViewController"
        case .manga, .editableManga, .friendManga:
            return "MangaDefaultCollectionViewController"
        default:
            abort()
        }
    }
    
    func setupCollectionViewController(_ controller: UICollectionViewController) {
        collectionViewController = controller
        
        let theme = ThemeManager.currentTheme
        controller.collectionView?.backgroundColor = .clear
        controller.collectionView?.indicatorStyle = theme.global.scrollIndicators.style

        controller.collectionView?.delegate = self
        controller.collectionView?.dataSource = self
        
        let layout = controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        if #available(iOS 11, *) {
            layout?.sectionInsetReference = .fromSafeArea
        }
        
        let refreshControl = UIRefreshControl()
        collectionViewRefreshControl = refreshControl
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(owner, action: #selector(owner.remoteReloadListIfNeeded), for: .valueChanged)
        controller.collectionView?.addSubview(refreshControl)
    }
}

// MARK: - Interactions
extension ListDisplayProxy {
    func refreshControlEndRefreshing() {
        switch currentStyle.kind {
        case .tableView:
            tableViewController?.refreshControl?.endRefreshing()
        case .collectionView:
            collectionViewRefreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        switch currentStyle.kind {
        case .tableView:
            tableViewController?.tableView?.reloadData()
        case .collectionView:
            collectionViewController?.collectionView?.reloadData()
        }
    }
    
    func toggleSectionsVisible(sections: IndexSet) {
        let animationDisabledThreshold = 20
        
        switch currentStyle.kind {
        case .tableView:
            sections.forEach { section in
                owner.sortedItems[section].metadata.expanded = !owner.sortedItems[section].metadata.expanded
            }
            
            if sections.count > animationDisabledThreshold {
                tableViewController?.tableView.reloadData()
            }
            else {
                tableViewController?.tableView?.reloadSections(sections, with: .fade)
            }

        case .collectionView:
            if let collectionView = collectionViewController?.collectionView {
                var insertIndexPaths: [IndexPath] = [], deleteIndexPaths: [IndexPath] = []
                
                sections.forEach { section in
                    let expanded = !owner.sortedItems[section].metadata.expanded
                    let itemsInSection = owner.sortedItems[section].items.count
                    let indexPaths = (0 ..< itemsInSection).map { IndexPath(row: $0, section: section) }
                    
                    if expanded {
                        insertIndexPaths.append(contentsOf: indexPaths)
                    }
                    else {
                        deleteIndexPaths.append(contentsOf: indexPaths)
                    }
                }
                
                if sections.count > animationDisabledThreshold {
                    collectionView.reloadData()
                }
                else {
                    collectionView.performBatchUpdates({
                        sections.forEach { section in
                            self.owner.sortedItems[section].metadata.expanded = !self.owner.sortedItems[section].metadata.expanded
                        }
                        
                        if !insertIndexPaths.isEmpty {
                            collectionView.insertItems(at: insertIndexPaths)
                        }
                        if !deleteIndexPaths.isEmpty {
                            collectionView.deleteItems(at: deleteIndexPaths)
                        }
                    }, completion: nil)
                    
                    sections.forEach { section in
                        refreshHeaderTitle(forSection: section)
                    }
                }
            }
        }
    }
    
    func reloadCells(at indexPaths: [IndexPath], animated: Bool) {
        switch currentStyle.kind {
        case .tableView:
            tableViewController?.tableView?.reloadRows(at: indexPaths, with: animated ? .fade : .none)
        case .collectionView:
            collectionViewController?.collectionView?.reloadItems(at: indexPaths)
        }
    }
    
    func moveCell(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        switch currentStyle.kind {
        case .tableView:
            tableViewController?.tableView?.moveRow(at: indexPath, to: newIndexPath)
        case .collectionView:
            collectionViewController?.collectionView?.moveItem(at: indexPath, to: newIndexPath)
        }
    }
    
    func insertCells(at indexPaths: [IndexPath], animated: Bool) {
        switch currentStyle.kind {
        case .tableView:
            tableViewController?.tableView?.insertRows(at: indexPaths, with: animated ? .fade : .none)
        case .collectionView:
            collectionViewController?.collectionView?.insertItems(at: indexPaths)
        }
    }
    
    func deleteCells(at indexPaths: [IndexPath], animated: Bool) {
        switch currentStyle.kind {
        case .tableView:
            tableViewController?.tableView?.deleteRows(at: indexPaths, with: animated ? .fade : .none)
        case .collectionView:
            collectionViewController?.collectionView?.deleteItems(at: indexPaths)
        }
    }
    
    var visibleCells: [EntityCell] {
        switch currentStyle.kind {
        case .tableView:
            return tableViewController?.tableView?.visibleCells.compactMap { $0 as? EntityCell } ?? []
        case .collectionView:
            return collectionViewController?.collectionView?.visibleCells.compactMap { $0 as? EntityCell } ?? []
        }
    }
    
    func visibleCellWithIndexPath(_ indexPath: IndexPath) -> EntityCell? {
        switch currentStyle.kind {
        case .tableView:
            if let tableView = tableViewController?.tableView {
                return tableView.visibleCells.find({ tableView.indexPath(for: $0) == indexPath }) as? EntityCell
            }
        case .collectionView:
            if let collectionView = collectionViewController?.collectionView {
                return collectionView.visibleCells.find({ collectionView.indexPath(for: $0) == indexPath }) as? EntityCell
            }
        }
        return nil
    }
    
    func updateHeaderTitle(_ title: String, forSection section: Int) {
        switch currentStyle.kind {
        case .tableView:
            if let header = tableViewController?.tableView?.headerView(forSection: section) as? EntityTableViewHeader {
                header.rightLabel.text = title
            }
        case .collectionView:
            if let header = collectionViewController?.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: section)) as? EntityCollectionReusableView {
                header.rightLabel.text = title
            }
        }
    }
    
    func refreshHeaderTitle(forSection section: Int) {
        switch currentStyle.kind {
        case .tableView:
            if let header = tableViewController?.tableView?.headerView(forSection: section) as? EntityTableViewHeader {
                fill(header: header, for: section)
            }
        case .collectionView:
            if let header = collectionViewController?.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: section)) as? EntityCollectionReusableView {
                fill(header: header, for: section)
            }
        }
    }
    
    func flashSelectCell(at indexPath: IndexPath) {
        switch currentStyle.kind {
        case .tableView:
            if let tableView = tableViewController?.tableView {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                delay(1.5) {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        case .collectionView:
            if let collectionView = collectionViewController?.collectionView {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                delay(1.5) {
                    collectionView.deselectItem(at: indexPath, animated: true)
                }
            }
        }
    }
    
    var footerView: UIView? {
        get {
            switch currentStyle.kind {
            case .tableView:
                return tableViewController?.tableView?.tableFooterView
            case .collectionView:
                return (collectionViewController?.collectionViewLayout as? FooterCollectionViewFlowLayout)?.globalFooterView
            }
        }
        set {
            switch currentStyle.kind {
            case .tableView:
                tableViewController?.tableView?.tableFooterView = newValue
            case .collectionView:
                if let layout = collectionViewController?.collectionViewLayout as? FooterCollectionViewFlowLayout {
                    layout.globalFooterView = newValue
                }
            }
        }
    }
    
    var scrollView: UIScrollView? {
        switch currentStyle.kind {
        case .tableView:
            return tableViewController?.tableView as UIScrollView?
        case .collectionView:
            return collectionViewController?.collectionView as UIScrollView?
        }
    }
}

// MARK: - TableView Delegate
extension ListDisplayProxy: UITableViewDataSource, UITableViewDelegate {
    func tableViewCellIdentifier() -> String {
        switch owner.cellType {
        case .anime:
            return "AnimeTableViewCell"
        case .editableAnime:
            return "EditableAnimeTableViewCell"
        case .friendAnime:
            return "FriendAnimeTableViewCell"
            
        case .manga:
            return "MangaTableViewCell"
        case .editableManga:
            return "EditableMangaTableViewCell"
        case .friendManga:
            return "FriendMangaTableViewCell"

        case .undefined:
            abort()
        }
    }
    
    func tableViewCellHeight() -> CGFloat {
        switch owner.cellType {
        case .anime, .editableAnime, .friendAnime, .manga, .editableManga, .friendManga:
            return 112

        case .undefined:
            abort()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return owner.sortedItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfos = owner.sortedItems[safe: section] {
            return sectionInfos.metadata.expanded ? sectionInfos.items.count : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier(), for: indexPath) as! EntityTableViewCell
        
        cell.longPressDelegate = owner
        if let item = owner.sortedItems[safe: indexPath.section]?.items[safe: indexPath.row] {
            owner.fill(cell: cell, withEntity: item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = owner.sortedItems[safe: indexPath.section]?.items[safe: indexPath.row] {
            DispatchQueue.main.async {
                self.owner.showEntityDetails(entity: item.series, context: self.owner.entityPresentingContext)
            }
        }
    }
    
    private func fill(header: EntityTableViewHeader, for section: Int) {
        if let sectionInfos = owner.sortedItems[safe: section] {
            let rightText = "\(sectionInfos.items.count)"
            header.fill(withSection: section, title: sectionInfos.title, rightText: rightText, context: .list(expanded: sectionInfos.metadata.expanded), pressedAction: { [weak self] section in
                self?.owner.sectionPressed(section)
            })
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EntityTableViewHeader") as? EntityTableViewHeader {
            fill(header: header, for: section)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Database.shared.entitiesTableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return Database.shared.entitiesTableViewHeaderHeight
    }
}


// MARK: - CollectionView Delegate
extension ListDisplayProxy: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionViewCellIdentifier() -> String {
        switch owner.cellType {
        case .editableAnime:
            if currentStyle == .collectionViewMinimalistic {
                return "MinimalisticAnimeCollectionViewCell"
            }
            return "EditableAnimeCollectionViewCell"
        case .editableManga:
            if currentStyle == .collectionViewMinimalistic {
                return "MinimalisticMangaCollectionViewCell"
            }
            return "EditableMangaCollectionViewCell"
        default:
            abort()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return owner.sortedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfos = owner.sortedItems[safe: section] {
            return sectionInfos.metadata.expanded ? sectionInfos.items.count : 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier(), for: indexPath) as! EntityCollectionViewCell
        
        cell.longPressDelegate = owner
        if let item = owner.sortedItems[safe: indexPath.section]?.items[safe: indexPath.row] {
            owner.fill(cell: cell, withEntity: item)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let item = owner.sortedItems[safe: indexPath.section]?.items[safe: indexPath.row] {
            DispatchQueue.main.async {
                self.owner.showEntityDetails(entity: item.series, context: self.owner.entityPresentingContext)
            }
        }
    }
    
    private func fill(header: EntityCollectionReusableView, for section: Int) {
        if let sectionInfos = owner.sortedItems[safe: section] {
            let rightText = "\(sectionInfos.items.count)"
            header.fill(withSection: section, title: sectionInfos.title, rightText: rightText, context: .list(expanded: sectionInfos.metadata.expanded), pressedAction: { [weak self] section in
                self?.owner.sectionPressed(section)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EntityCollectionReusableView", for: indexPath) as? EntityCollectionReusableView {
                fill(header: header, for: indexPath.section)
                return header
            }
        }
        return UICollectionReusableView()
    }
    
    private var collectionViewCellRatio: CGSize {
        return CGSize(width: 15, height: 21)
    }
    
    private var collectionViewCellAdditionalHeight: CGFloat {
        if currentStyle == .collectionViewMinimalistic {
            return 5
        }
        return 35
    }
    
    private func numberOfCellPerRow(with containerSize: CGSize) -> Int {
        // UIApplication.shared.statusBarOrientation.isPortrait is incorrect when a controller is presented on top (iOS 10), and UIDevice.current.orientation.isPortrait could be dangerous
        let isPortrait = containerSize.height > containerSize.width
        let isiPad = UIDevice.current.isiPad()
        let hasCompactWidth = (collectionViewController?.traitCollection.horizontalSizeClass).map { $0 == .compact } ?? false
        let hasLargeDisplay = isiPad && !hasCompactWidth
        
        switch currentStyle {
        case .collectionViewDefault:
            return hasLargeDisplay ? (isPortrait ? 4 : 6) : (isPortrait ? 2 : 4)
        case .collectionViewSmall, .collectionViewMinimalistic:
            return hasLargeDisplay ? (isPortrait ? 6 : 8) : (isPortrait ? 3 : 5)
        default:
            return 0
        }
    }
    
    private func collectionViewCellSize(with layout: UICollectionViewFlowLayout, containerSize: CGSize, numberOfCellPerRow: Int) -> CGSize {
        let normalizedContainerWidth = containerSize.width - (layout.sectionInset.left + layout.sectionInset.right)
        let width = (normalizedContainerWidth - (layout.minimumInteritemSpacing * CGFloat(numberOfCellPerRow - 1))) / CGFloat(numberOfCellPerRow)
        let height = (width * collectionViewCellRatio.height / collectionViewCellRatio.width) + collectionViewCellAdditionalHeight
        
        return CGSize(width: floor(width), height: floor(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var containerSize = AppDelegate.shared.viewPortSize

        if #available(iOS 11.0, *) {
            let safeAreaInsets = collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
            containerSize.width -= safeAreaInsets
        }
        
        let numberOfCellPerRow = self.numberOfCellPerRow(with: containerSize)
        
        return collectionViewCellSize(with: collectionViewLayout as! UICollectionViewFlowLayout, containerSize: containerSize, numberOfCellPerRow: numberOfCellPerRow)
    }
}
