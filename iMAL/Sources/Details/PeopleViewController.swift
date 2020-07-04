//
//  PeopleViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 27/05/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class PeopleViewController: RootViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var otherNamesLabel: UILabel!
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var favouriteCountLabel: UILabel!
    @IBOutlet var bodyContentLabel: UILabel!
    @IBOutlet var bodyContainerView: UIView!
    
    @IBOutlet var tableView: UITableView!
    
    private var filterButton: ListFilterBarButtonItem!
    
    private var preloadedVoiceActor: Cast.VoiceActor?
    private var preloadedCast: Cast?
    private var peopleIdentifier: Int = 0
    
    private var people: People!
    private var sections: [(title: String, items: [AnyObject])] = []
    
    class func controller(withVoiceActor va: Cast.VoiceActor) -> PeopleViewController? {
        if let controller = UIStoryboard(name: "People", bundle: nil).instantiateInitialViewController() as? PeopleViewController {
            controller.preloadedVoiceActor = va
            controller.peopleIdentifier = va.identifier
            return controller
        }
        return nil
    }
    
    class func controller(withCastMember cast: Cast) -> PeopleViewController? {
        if let controller = UIStoryboard(name: "People", bundle: nil).instantiateInitialViewController() as? PeopleViewController {
            controller.preloadedCast = cast
            controller.peopleIdentifier = cast.identifier
            return controller
        }
        return nil
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        initialLayout()
        
        tableView.register(UINib(nibName: "FriendsTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "PeopleTableViewHeader")
        
        API.getPeople(identifier: peopleIdentifier).request(loadingDelegate: self) { (success: Bool, people: People?) in
            if success, let people = people {
                self.people = people
                self.loadContent(with: people)
            }
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.genericView.importantText.color
            
            self.reloadContent()
        }
    }
    
    func reloadContent() {
        if let people = people {
            loadContent(with: people)
        }
        if let va = preloadedVoiceActor {
            preloadContent(with: va)
        }
        else if let cast = preloadedCast {
            preloadContent(with: cast)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHeader()
    }
    
    private func presentEntityDetailsView(entity: Entity) {
        if let controller = EntityDetailsViewController.controller(for: entity) {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - Layout
private extension PeopleViewController {
    func initialLayout() {
        bodyContainerView.isHidden = true

        pictureImageView.layer.cornerRadius = 12
        pictureImageView.layer.masksToBounds = true
        
        headerView.removeFromSuperview()
        headerView.autoresizingMask = .flexibleWidth
        headerView.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = headerView
    }
    
    func layoutHeader() {
        if let header = tableView.tableHeaderView {
            header.setNeedsLayout()
            header.layoutIfNeeded()
            let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            
            var frame = header.frame
            if height != frame.size.height {
                frame.size.height = height
                header.frame = frame
                
                tableView.tableHeaderView = header
            }
        }
    }
}

// MARK: - Content
extension PeopleViewController {
    @IBAction func filterPressed() {
        loadEntityList(if: !people.voiceActingRoles.isEmpty || !people.animeStaffPositions.isEmpty, type: .anime) {
            self.loadEntityList(if: !self.people.publishedManga.isEmpty, type: .manga) {
                self.reloadRolesContent()
            }
        }
    }
}

private extension PeopleViewController {
    func loadEntityList(if condition: Bool, type: EntityKind, completion: @escaping () -> Void) {
        if condition {
            CurrentUser.me.requireUserList(type: type, loadingDelegate: self, completion: completion)
        }
        else {
            completion()
        }
    }
    
    func preloadContent(with va: Cast.VoiceActor) {
        title = va.name
        pictureImageView.setImageWithURLString(va.imageURL)
        nameLabel.text = va.name
    }
    
    func preloadContent(with member: Cast) {
        title = member.name
        pictureImageView.setImageWithURLString(member.imageURL)
        nameLabel.text = member.name
    }
    
    func loadContent(with people: People) {
        let theme = ThemeManager.currentTheme.genericView
        
        title = people.name
        pictureImageView.setImageWithURLString(people.imageURL)
        
        let nameContent = NSMutableAttributedString()
        nameContent.append(NSAttributedString(string: people.name, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22, weight: .medium), NSAttributedStringKey.foregroundColor: theme.importantText.color]))
        if !people.japaneseName.isEmpty {
            nameContent.append(NSAttributedString(string: "\n\(people.japaneseName)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20), NSAttributedStringKey.foregroundColor: theme.importantSubtitleText.color]))
        }
        nameLabel.attributedText = nameContent
        
        otherNamesLabel.attributedText = buildLabeledValue(label: "Alternative names", content: people.otherNames.joined(separator: ", "), hideIfEmpty: true)
        birthdayLabel.attributedText = buildLabeledValue(label: "Birthday", content: people.birthday?.shortDateDisplayString ?? "Unknown")
        favouriteCountLabel.attributedText = buildLabeledValue(label: "Member favorites", content: people.favouriteCount.formattedString)
        
        bodyContentLabel.attributedText = buildHTMLContent(contentText: people.details)
        
        buildFilterButton()
        reloadRolesContent()
        layoutHeader()
        
        bodyContainerView.isHidden = false
    }
    
    func buildFilterButton() {
        filterButton = ListFilterBarButtonItem(owner: self, filterChanged: { [weak self] _ in self?.filterPressed() })
        filterButton.displayStrings = ["No filter", "Only watching or completed", "Only in my list"]
        filterButton.tintColor = ThemeManager.currentTheme.global.bars.content.color
        navigationItem.rightBarButtonItem = filterButton
    }
    
    func buildLabeledValue(label: String, content: String, hideIfEmpty: Bool = false) -> NSAttributedString? {
        if hideIfEmpty && content.isEmpty {
            return nil
        }
        
        let theme = ThemeManager.currentTheme.genericView
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "\(label): ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: theme.labelText.color]))
        string.append(NSAttributedString(string: content, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .medium), NSAttributedStringKey.foregroundColor: theme.importantText.color]))
        return string
    }

    func buildHTMLContent(contentText: String?) -> NSAttributedString? {
        do {
            if let contentText = contentText {
                let content = EntityHTMLRepresentation.htmlTemplate(withContent: contentText, color: ThemeManager.currentTheme.genericView.htmlLongDescription.color)
                if let data = content.data(using: String.Encoding.unicode, allowLossyConversion: true) {
                    let parsedContent = try NSAttributedString(data: data,
                                                               options: [.documentType: NSAttributedString.DocumentType.html,
                                                                         .characterEncoding: String.Encoding.utf8.rawValue],
                                                               documentAttributes: nil)
                    
                    return EntityHTMLRepresentation.colorLinks(forHTMLContent: parsedContent)
                }
            }
        }
        catch {}
        return nil
    }
}

private extension PeopleViewController {
    func computeSections() {
        if let people = people {
            sections = [(title: "Voice acting roles", items: filteredItems(people.voiceActingRoles)),
                        (title: "Anime staff positions", items: filteredItems(people.animeStaffPositions)),
                        (title: "Published manga", items: filteredItems(people.publishedManga))].filter { !$0.items.isEmpty }
        }
        else {
            sections = []
        }
    }
    
    func filteredItems(_ items: [AnyObject]) -> [AnyObject] {
        guard filterButton.currentFilter != .none else {
            return items
        }
        
        if let items = items as? [People.VoiceActingRole] {
            return items.filter { shouldIncludeEntity($0.anime, filter: filterButton.currentFilter) }
        }
        else if let items = items as? [People.StaffPosition] {
            return items.filter { shouldIncludeEntity($0.entity, filter: filterButton.currentFilter) }
        }
        return items
    }
    
    func shouldIncludeEntity(_ entity: Entity, filter: ListFilter) -> Bool {
        if let anime = entity as? Anime {
            if let userInfo = CurrentUser.me.cachedAnimeList()?.find(by: anime.identifier) {
                return filter == .full || (userInfo.status == .watching || userInfo.status == .completed)
            }
            return filter == .none
        }
        else if let manga = entity as? Manga {
            if let userInfo = CurrentUser.me.cachedMangaList()?.find(by: manga.identifier) {
                return filter == .full || (userInfo.status == .watching || userInfo.status == .completed)
            }
            return filter == .none
        }
        return false
    }
    
    func reloadRolesContent() {
        computeSections()
        tableView.reloadData()
    }
}

// MARK: - TableView
extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && !people.voiceActingRoles.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleVoiceActingRoleTableViewCell", for: indexPath) as! PeopleVoiceActingRoleTableViewCell
            
            cell.fill(with: sections[indexPath.section].items[indexPath.row] as! People.VoiceActingRole)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleStaffPositionTableViewCell", for: indexPath) as! PeopleStaffPositionTableViewCell
            
            cell.fill(with: sections[indexPath.section].items[indexPath.row] as! People.StaffPosition)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && !people.voiceActingRoles.isEmpty {
            let item = sections[indexPath.section].items[indexPath.row] as! People.VoiceActingRole
            presentEntityDetailsView(entity: item.anime)
        }
        else {
            let item = sections[indexPath.section].items[indexPath.row] as! People.StaffPosition
            presentEntityDetailsView(entity: item.entity)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PeopleTableViewHeader") as? FriendsTableViewHeader {
            
            let title = sections[section].title
            let rightText = "\(sections[section].items.count)"
            header.fill(with: title, rightText: rightText)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Database.shared.entitiesTableViewHeaderHeight
    }
}
