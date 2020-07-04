//
//  BrowseScheduleViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseScheduleViewController: RootViewController {
    var tableView: UITableView! {
        return tableViewController?.tableView
    }
    var tableViewController: UITableViewController!
    
    private var baseData = AnimeSchedule()
    private var sections: [AnimeSchedule.Section] = []
    private var rawSections: [AnimeSchedule.Section] = []
    
    private var pinchToCollapseGestureRecognizer: UIPinchGestureRecognizer?
    
    private var filterButton: ListFilterBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        setupGestures()
        buildFilterButton()
        
        CurrentUser.me.observing.observe(from: self, options: .all) { [weak self] _ in
            self?.tableView?.reloadData()
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView?.backgroundColor = theme.global.viewBackground.color
            self.tableView?.separatorColor = theme.separators.heavy.color
            self.tableView?.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView?.reloadData()
        }
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UITableViewController" {
            tableViewController = segue.destination as? UITableViewController
            
            tableViewController.tableView.register(UINib(nibName: "EntityTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "EntityTableViewHeader")
            tableViewController.tableView.delegate = self
            tableViewController.tableView.dataSource = self
            
            loadContent()
        }
    }
}

private extension BrowseScheduleViewController {
    func shouldIncludeEntity(_ entity: Entity) -> Bool {
        return !(Settings.filterRatedX && entity.classification == EntityRating.hentai.shortSymbol)
    }
    
    func loadContent() {
        API.getAnimeSchedule.request(loadingDelegate: self) { (success: Bool, data: AnimeSchedule?) in
            if success, let data = data {
                self.baseData = data
                self.reloadContent()
            }
        }
    }
    
    func reloadContent() {
        if Settings.airingDatesEnabled, let airingData = Database.shared.airingAnime {
            rawSections = buildSections(using: airingData)
        }
        else {
            rawSections = baseData.sections
        }
        
        filterSections()
        tableView.reloadData()
    }
    
    func sectionPressed(_ section: Int) {
        if sections[safe: section] != nil {
            sections[section].metadata.expanded = !sections[section].metadata.expanded
            tableView.reloadSections(IndexSet(integer: section), with: .fade)
        }
    }
}

// MARK: - Filter
private extension BrowseScheduleViewController {
    func buildFilterButton() {
        filterButton = ListFilterBarButtonItem(owner: self, filterChanged: { [weak self] _ in self?.filterPressed() })
        filterButton.displayStrings = ["No filter", "Only watching or plan to watch", "Only in my list"]
        navigationItem.rightBarButtonItem = filterButton
    }
    
    func filterPressed() {
        filterSections()
        tableView.reloadData()
    }
    
    func filterSections() {
        if filterButton.currentFilter == .none {
            sections = rawSections
            return
        }
        
        sections = rawSections.compactMap(self.filteredSection)
    }
    
    func filteredSection(section: AnimeSchedule.Section) -> AnimeSchedule.Section? {
        let filter = filterButton.currentFilter
        let items = section.items.filter { item in
            if let userInfo = CurrentUser.me.cachedAnimeList()?.find(by: item.identifier) {
                return filter == .full || (userInfo.status == .watching || userInfo.status == .planToWatch)
            }
            return filter == .none
        }
        return items.isEmpty ? nil : AnimeSchedule.Section(name: section.name, items: items, thisWeek: section.metadata.thisWeek)
    }
}

// MARK: - Sorting/Grouping
private extension BrowseScheduleViewController {
    func buildEpisodeCache(for airingData: AiringData) -> [Int: Date] {
        var episodesCache: [Int: Date] = [:]
        let targetDate = Calendar.current.startOfDay(for: Date())
        
        airingData.anime.forEach { anime in
            if let episode = anime.nextEpisode(after: targetDate) {
                episodesCache[anime.identifier] = episode.time
            }
        }
        
        return episodesCache
    }
    
    func buildSections(using airingData: AiringData) -> [AnimeSchedule.Section] {
        var allAnime = baseData.sections.flatMap { $0.items }
        let episodesCache = buildEpisodeCache(for: airingData)
        
        allAnime.sort { a, b in
            if let epA = episodesCache[a.identifier] {
                if let epB = episodesCache[b.identifier] {
                    return epA < epB
                }
                return true
            }
            return episodesCache[b.identifier] != nil ? false : a.name.lowercased() < b.name.lowercased()
        }
        
        var rawSections: [(component: Calendar.Component, offset: Int, title: String, items: [Anime])] = [
            (.day, 0, "Today - {date}", []),
            (.day, 1, "Tomorrow - {date}", []),
            (.day, 2, "{date}", []),
            (.day, 3, "{date}", []),
            (.day, 4, "{date}", []),
            (.day, 5, "{date}", []),
            (.day, 6, "{date}", []),
            (.weekOfYear, 1, "Next week", []),
            (.month, 0, "This month", []),
            (.month, 1, "Next month", []),
            (.year, 0, "This year", []),
            (.year, 1, "Next year", []),
        ]
        
        var unknownList: [Anime] = []

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        allAnime.forEach { anime in
            if let nextEpisodeTime = episodesCache[anime.identifier] {
                let sectionIndex = rawSections.index { raw in
                    if let targetDate = calendar.date(byAdding: raw.component, value: raw.offset, to: today) {
                        return calendar.isDate(nextEpisodeTime, equalTo: targetDate, toGranularity: raw.component)
                    }
                    return false
                }
                
                if let sectionIndex = sectionIndex {
                    rawSections[sectionIndex].items.append(anime)
                }
                else {
                    unknownList.append(anime)
                }
            }
            else {
                unknownList.append(anime)
            }
        }
        
        let formatter = SharedFormatters.englishWeekdayDisplayFormatter
        
        var sections: [AnimeSchedule.Section] = rawSections.compactMap { section in
            if section.items.isEmpty {
                return nil
            }
            
            let targetDate = calendar.date(byAdding: section.component, value: section.offset, to: today) ?? today
            let name = section.title.replacingOccurrences(of: "{date}", with: formatter.string(from: targetDate).capitalized)
            
            return AnimeSchedule.Section(name: name, items: section.items, thisWeek: section.title.contains("{date}"))
        }
        
        if !unknownList.isEmpty {
            sections.append(AnimeSchedule.Section(name: "Unknown", items: unknownList))
        }
        
        return sections
    }
}

// MARK: - TableView Delegate
extension BrowseScheduleViewController: UITableViewDataSource, UITableViewDelegate, EntityCellLongPressDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].metadata.expanded ? sections[section].items.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseScheduleTableViewCell", for: indexPath) as! BrowseScheduleTableViewCell
        
        cell.longPressDelegate = self
        if let item = sections[safe: indexPath.section]?.items[safe: indexPath.row] {
            cell.fill(with: item, section: sections[indexPath.section])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = sections[safe: indexPath.section]?.items[safe: indexPath.row] {
            DispatchQueue.main.async {
                self.showEntityDetails(entity: item)
            }
        }
    }
    
    func didLongPressCell(_ cell: EntityOwnerCell) {
        showEntityDetails(entity: cell.entity, alternativeAction: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 142
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EntityTableViewHeader") as? EntityTableViewHeader,
            let sectionInfos = sections[safe: section] {
            
            let rightText = "\(sectionInfos.items.count)"
            header.fill(withSection: section, title: sectionInfos.name, rightText: rightText, context: .schedule(expanded: sectionInfos.metadata.expanded), pressedAction: { [weak self] section in
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

// MARK: - Gestures
extension BrowseScheduleViewController: UIGestureRecognizerDelegate {
    func setupGestures() {
        pinchToCollapseGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.userDidPinchView(_:)))
        pinchToCollapseGestureRecognizer!.delegate = self
        tableView.addGestureRecognizer(pinchToCollapseGestureRecognizer!)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pinchToCollapseGestureRecognizer {
            return Settings.pinchToCollapseEnabled
        }
        return true
    }
    
    @objc func userDidPinchView(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches == 2 && recognizer.scale < 0.7 {
            let sectionsPaths = NSMutableIndexSet()
            
            for index in 0 ..< sections.count {
                if sections[index].metadata.expanded {
                    sections[index].metadata.expanded = false
                    sectionsPaths.add(index)
                }
            }
            
            if sectionsPaths.count > 0 {
                tableView.reloadSections(sectionsPaths as IndexSet, with: .fade)
            }
        }
    }
}
