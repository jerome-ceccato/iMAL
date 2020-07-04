//
//  EntityCastViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCastViewController: RootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UILabel!
    
    @IBOutlet var filterButton: UIBarButtonItem!
    
    private var entity: TypedEntity!
    
    private var characters: [Cast] = []
    private var staff: [Cast] = []
    
    private var data: [[Cast]] = []
    private var languages: [String] = []
    private var filteredLanguage: String?
    
    private var charactersFlatIndex: [(character: Cast, va: Cast.VoiceActor?, first: Bool)] = []
    
    class func controller(withEntity entity: TypedEntity) -> EntityCastViewController? {
        if let controller = UIStoryboard(name: "EntityDetailsMoreInfo", bundle: nil).instantiateViewController(withIdentifier: "EntityCastViewController") as? EntityCastViewController {
            controller.entity = entity
            
            return controller
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = nil
        
        tableView.register(UINib(nibName: "FriendsTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CastTableViewHeader")
        
        reloadPageTitle()
        
        tableView.isHidden = true
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            self.filterButton.tintColor = theme.global.bars.content.color
            self.tableView.reloadData()
            
            self.emptyView.textColor = theme.genericView.labelText.color
        }
        
        loadNewData()
    }
    
    private func loadLanguagePreference(with languages: [String]) {
        if filteredLanguage == nil {
            if let prefered = Settings.preferedVoiceActorLanguage {
                if languages.count > 1 && languages.contains(prefered) {
                    filteredLanguage = prefered
                    reloadPageTitle()
                }
            }
        }
    }
    
    private func reloadPageTitle() {
        if let language = filteredLanguage {
            title = language
            filterButton.image = #imageLiteral(resourceName: "Language-on").withRenderingMode(.alwaysTemplate)
        }
        else {
            filterButton.image = #imageLiteral(resourceName: "Language").withRenderingMode(.alwaysTemplate)
            switch entity.kind {
            case .anime:
                title = "Characters & Staff"
            case .manga:
                title = "Characters"
            }
        }
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        return nil
    }
    
    private func castAPI() -> API {
        switch entity.kind {
        case .anime:
            return API.getAnimeCast(anime: entity.anime!)
        case .manga:
            return API.getMangaCast(manga: entity.manga!)
        }
    }
    
    @IBAction func loadNewData() {
        castAPI().request(loadingDelegate: self) { (success: Bool, cast: [String: [Cast]]?) in
            if success, let cast = cast {
                self.characters = cast["Characters"] ?? []
                self.staff = cast["Staff"] ?? []
            }
            self.reloadData()
        }
    }
    
    private func reloadData() {
        data = [characters, staff].filter { !$0.isEmpty }

        buildLanguageArray()
        loadLanguagePreference(with: languages)
        
        buildCharactersFlatIndex(filter: { actor in
            if let filter = self.filteredLanguage {
                return actor.language == filter
            }
            return true
        })
        
        tableView.contentOffset = CGPoint(x: 0, y: -tableView.trueContentInset.top)
        tableView.reloadData()
        tableView.isHidden = data.isEmpty
        emptyView.isHidden = !data.isEmpty
        
        reloadPageTitle()
    }
    
    func buildCharactersFlatIndex(filter: (Cast.VoiceActor) -> Bool) {
        charactersFlatIndex = characters.flatMap { cast -> [(character: Cast, va: Cast.VoiceActor?, first: Bool)] in
            let filteredVA = cast.voiceActors.filter(filter)
            var ret: [(character: Cast, va: Cast.VoiceActor?, first: Bool)] = [(cast, filteredVA.first, first: true)]
            if filteredVA.count > 1 {
                ret.append(contentsOf: filteredVA.suffix(from: 1).map({ (character: cast, va: $0, first: false) }))
            }
            return ret
        }
    }
    
    func buildLanguageArray() {
        var availableLanguages: [String: Bool] = [:]
        characters.forEach({ $0.voiceActors.forEach({ availableLanguages[$0.language] = true }) })
        languages = availableLanguages.map { $0.key }
        
        navigationItem.rightBarButtonItem = languages.count > 1 ? filterButton : nil
    }
    
    @IBAction func filterPressed() {
        if let actionSheet = ManagedActionSheetViewController.actionSheet(withTitle: "Voice actors") {
            languages.forEach { lang in
                actionSheet.addAction(ManagedActionSheetAction(title: lang, style: .default, action: { 
                    self.filteredLanguage = lang
                    Settings.preferedVoiceActorLanguage = lang
                    self.reloadData()
                }))
            }
            
            actionSheet.addAction(ManagedActionSheetAction(title: "All languages", style: .default, action: { 
                self.filteredLanguage = nil
                Settings.preferedVoiceActorLanguage = nil
                self.reloadData()
            }))
            
            DispatchQueue.main.async {
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    func userDidPressCell(side: EntityCastBaseTableViewCell.Position, left: Cast, right: Cast.VoiceActor) {
        if side == .left {
            showCharacterController(with: left)
        }
        else {
            showPeopleController(with: right)
        }
    }
    
    func showCharacterController(with character: Cast) {
        character.characterURL?.open(in: self)
    }
    
    func showPeopleController(with va: Cast.VoiceActor) {
        if let controller = PeopleViewController.controller(withVoiceActor: va) {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showPeopleController(with cast: Cast) {
        if let controller = PeopleViewController.controller(withCastMember: cast) {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension EntityCastViewController: UITableViewDelegate, UITableViewDataSource {    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? charactersFlatIndex.count : data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let item = charactersFlatIndex[indexPath.row]
            if item.first {
                if let actor = item.va {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EntityCastDualCharacterTableViewCell", for: indexPath) as! EntityCastDualCharacterTableViewCell
                    
                    cell.fill(with: item.character, voiceActor: actor)
                    cell.action = { [weak self] side in self?.userDidPressCell(side: side, left: item.character, right: actor) }
                    cell.separatorView?.isHidden = indexPath.row == 0
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EntityCastCharacterTableViewCell", for: indexPath) as! EntityCastCharacterTableViewCell
                    
                    cell.fill(with: item.character)
                    cell.action = { [weak self] _ in self?.showCharacterController(with: item.character) }
                    cell.separatorView?.isHidden = indexPath.row == 0
                    return cell
                }
            }
            else {
                let actor = item.va!
                let cell = tableView.dequeueReusableCell(withIdentifier: "EntityCastVoiceActorTableViewCell", for: indexPath) as! EntityCastVoiceActorTableViewCell
                
                cell.fill(with: actor)
                cell.action = { [weak self] side in self?.userDidPressCell(side: side, left: item.character, right: actor) }
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EntityCastStaffTableViewCell", for: indexPath) as! EntityCastStaffTableViewCell
            
            let item = data[indexPath.section][indexPath.row]
            cell.fill(with: item)
            cell.action = { [weak self] _ in self?.showPeopleController(with: item) }
            cell.separatorView?.isHidden = indexPath.row == 0
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CastTableViewHeader") as? FriendsTableViewHeader {
            
            let title = section == 0 ? "Characters" : "Staff"
            let rightText = "\(data[section].count)"
            header.fill(with: title, rightText: rightText)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Database.shared.entitiesTableViewHeaderHeight
    }
}
