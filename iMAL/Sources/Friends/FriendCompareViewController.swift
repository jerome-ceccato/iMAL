//
//  FriendCompareViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 20/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendCompareViewController: RootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!

    @IBOutlet var friendPictureImageView: UIImageView!
    @IBOutlet var myColumnTitleLabel: UILabel!
    @IBOutlet var theirColumnTitleLabel: UILabel!
    @IBOutlet var myMeanScoreLabel: UILabel!
    @IBOutlet var theirMeanScoreLabel: UILabel!
    @IBOutlet var differenceTitleLabel: UILabel!
    @IBOutlet var differenceScoreLabel: UILabel!
    
    @IBOutlet var sortButton: UIBarButtonItem!
    
    var entityName: String {
        return "Entity"
    }
    
    enum SortStyle {
        case alphabetically
        case score
    }
    
    var friend: Friend!
    var friendList: [UserEntity] = []
    
    private var data: [Section] = []
    private var sortStyle: SortStyle = .alphabetically
    
    struct Section {
        typealias ScoreEntity = (entity: Entity, myScore: Int, theirScore: Int)
        
        var title: String
        var items: [ScoreEntity]
        var expanded: Bool = true
        
        init(title: String, items: [ScoreEntity] = []) {
            self.title = title
            self.items = items
        }
    }
    
    deinit {
        NotificationCenter.unregister(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.isHidden = true
        
        title = "Shared \(entityName)"
        
        tableView.register(UINib(nibName: "EntityTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "EntityTableViewHeader")
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            
            self.headerView.backgroundColor = theme.genericView.headerBackground.color
            self.friendPictureImageView.backgroundColor = theme.entity.pictureBackground.color
            [self.myColumnTitleLabel,
             self.theirColumnTitleLabel,
             self.differenceTitleLabel,
             self.myMeanScoreLabel,
             self.theirMeanScoreLabel,
             self.differenceScoreLabel].forEach { label in
                label?.textColor = theme.genericView.importantText.color
            }
            
            self.tableView.backgroundColor = theme.global.viewBackground.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.reloadData()
        }
    }
    
    private func sectionPressed(_ section: Int) {
        data[section].expanded = !data[section].expanded
        tableView.reloadSections(IndexSet(integer: section), with: .fade)
    }
    
    @IBAction func sortPressed() {
        sortStyle = sortStyle == .alphabetically ? .score : .alphabetically
        
        if sortStyle == .alphabetically {
            sortButton.image = #imageLiteral(resourceName: "Sort-Score")
        }
        else {
            sortButton.image = #imageLiteral(resourceName: "Sort-AZ")
        }
        
        sortSections()
        tableView.reloadData()
    }
}

// MARK: - Content
extension FriendCompareViewController {
    func reloadContent(withMyList items: [UserEntity]) {
        buildContent(withMyList: items, theirList: friendList)
        updateHeader(withMyList: items, theirList: friendList)
        tableView.reloadData()
    }
    
    private func buildLookupTable(with list: [UserEntity]) -> [Int: UserEntity] {
        return list.reduce(into: [:], { (result, entity) in
            result[entity.series.identifier] = entity
        })
    }
    
    private func buildContent(withMyList me: [UserEntity], theirList them: [UserEntity]) {
        var shared = Section(title: "Shared \(entityName)")
        var uniqueToMe = Section(title: "Unique to \(CurrentUser.me.currentUsername)")
        var uniqueToThem = Section(title: "Unique to \(friend.name)")
        
        let myListLookup = buildLookupTable(with: me)
        let theirListLookup = buildLookupTable(with: them)
        
        for item in me {
            if let theirEntity = theirListLookup[item.series.identifier] {
                shared.items.append((entity: item.series, myScore: item.score, theirScore: theirEntity.score))
            }
            else {
                uniqueToMe.items.append((entity: item.series, myScore: item.score, theirScore: 0))
            }
        }
        
        for item in them {
            if myListLookup[item.series.identifier] == nil {
                uniqueToThem.items.append((entity: item.series, myScore: 0, theirScore: item.score))
            }
        }
        
        data = [shared, uniqueToMe, uniqueToThem].filter { !$0.items.isEmpty }
        sortSections()
    }
    
    private func sortSections() {
        for i in 0 ..< data.count {
            switch sortStyle {
            case .alphabetically:
                data[i].items.sort { (a, b) in
                    a.entity.name.lowercased() < b.entity.name.lowercased()
                }
            case .score:
                data[i].items.sort { (a, b) in
                    if a.theirScore != b.theirScore {
                        return a.theirScore > b.theirScore
                    }
                    if a.myScore != b.myScore {
                        return a.myScore > b.myScore
                    }
                    return a.entity.name.lowercased() < b.entity.name.lowercased()
                }
            }
        }
    }
    
    private func updateHeader(withMyList me: [UserEntity], theirList them: [UserEntity]) {
        myColumnTitleLabel.text = CurrentUser.me.currentUsername
        theirColumnTitleLabel.text = friend.name
        
        let myScore = meanScore(for: me)
        let theirScore = meanScore(for: them)
        
        myMeanScoreLabel.text = myScore.isNaN ? "-" : String(format: "%.2f", myScore)
        theirMeanScoreLabel.text = theirScore.isNaN ? "-" : String(format: "%.2f", theirScore)
        differenceScoreLabel.text = (theirScore - myScore).isNaN ? "-" : String(format: "%+.2f", theirScore - myScore)
        
        let theme = ThemeManager.currentTheme
        if myScore < theirScore {
            differenceScoreLabel.textColor = theme.misc.comparisonPositive.color
        }
        else if myScore > theirScore {
            differenceScoreLabel.textColor = theme.misc.comparisonNegative.color
        }
        else {
            differenceScoreLabel.textColor = theme.genericView.importantText.color
        }

        if let avatar = friend.avatarURL {
            friendPictureImageView.setImageWithURLString(avatar)
        }
        headerView.isHidden = false
    }
    
    private func meanScore(for list: [UserEntity]) -> CGFloat {
        let result = list.reduce((total: 0, count: 0), { (acc, item) in
            (total: acc.total + item.score, count: acc.count + (item.score > 0 ? 1 : 0))
        })
        return CGFloat(result.total) / CGFloat(result.count)
    }
}

// MARK: - TableView
extension FriendCompareViewController: UITableViewDelegate, UITableViewDataSource, EntityCellLongPressDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].expanded ? data[section].items.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCompareTableViewCell", for: indexPath) as! FriendCompareTableViewCell
        
        cell.longPressDelegate = self
        cell.fill(with: data[indexPath.section].items[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showEntityDetails(entity: data[indexPath.section].items[indexPath.row].entity)
    }
    
    func didLongPressCell(_ cell: EntityOwnerCell) {
        showEntityDetails(entity: cell.entity, alternativeAction: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EntityTableViewHeader") as? EntityTableViewHeader {
            
            let rightText = "\(data[section].items.count)"
            header.fill(withSection: section, title: data[section].title, rightText: rightText, context: .friendlist(expanded: data[section].expanded), pressedAction: { [weak self] section in
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
