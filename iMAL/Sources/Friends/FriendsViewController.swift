//
//  FriendsViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 11/11/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class FriendsViewController: RootViewController {
    @IBOutlet var tableView: UITableView!
    
    private var MALFriends: [Friend] = []
    private var localFriends: [Friend] = []
    private var friends: [[Friend]] {
        return [MALFriends, localFriends].compactMap { $0.isEmpty ? nil : $0 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadContent()
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = UIColor.clear
        
        tableView.register(UINib(nibName: "FriendsTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "FriendsTableViewHeader")
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView.separatorColor = theme.separators.heavy.color
            self.tableView.reloadData()
        }
    }
    
    private func reloadContent() {
        API.getFriends(username: CurrentUser.me.currentUsername).request(loadingDelegate: self) { (success, friends: [Friend]?) in
            if let friends = friends, success {
                self.MALFriends = self.sortedFriends(friends)
                self.tableView.reloadData()
            }
        }
        
        localFriends = sortedFriends(Database.loadFriends())
        self.tableView.reloadData()
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        if error.code == 404 {
            return ErrorCenter.Message(title: "Not found", body: "There is no user with the specified username.", cancelAction: ErrorCenter.Action(name: "OK", callback: nil))
        }
        return super.messageForNetworkError(error)
    }
}

// MARK: - Actions
extension FriendsViewController {
    @IBAction func addFriendPressed() {
        let alert = UIAlertController(title: "Add friend", message: "iMAL cannot add friends to your MAL friend list, but you can add local friends to see their lists in the app.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Username"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let textField = alert.textFields?.first {
                self.addFriend(textField.textString)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

private extension FriendsViewController {
    func sortedFriends(_ friends: [Friend]) -> [Friend] {
        return friends.sorted { a, b in
            a.name.lowercased() < b.name.lowercased()
        }
    }
    
    func addFriend(_ username: String) {
        guard !username.isEmpty else {
            return
        }
        
        API.getAvatarURL(username: username).request(loadingDelegate: self) { (success, url: String??) in
            if let url = url, success {
                let newFriend = Friend(name: username, avatarURL: url)
                self.localFriends.append(newFriend)
                self.localFriends = self.sortedFriends(self.localFriends)
                
                Database.saveFriends(self.localFriends)
                self.tableView.reloadData()
                
                if let index = self.localFriends.index(where: { $0.name == newFriend.name }) {
                    let indexPath = IndexPath(row: index, section: self.friends.index(where: { $0 == self.localFriends}) ?? 0)
                    self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
            }
        }
    }
    
    func showAnimeList(_ friend: Friend, fromIndexPath indexPath: IndexPath) {
        CurrentUser.me.requireUserList(type: .anime, loadingDelegate: self) {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FriendAnimeListViewController") as? FriendAnimeListViewController {
                controller.friend = friend
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }
    
    func showMangaList(_ friend: Friend, fromIndexPath indexPath: IndexPath) {
        CurrentUser.me.requireUserList(type: .manga, loadingDelegate: self) {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FriendMangaListViewController") as? FriendMangaListViewController {
                controller.friend = friend
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }
}

// MARK: - TableView
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        
        cell.fill(with: friends[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.section][indexPath.row]
        if let actionSheet = ManagedActionSheetViewController.actionSheet(withTitle: friend.name) {
            actionSheet.addAction(ManagedActionSheetAction(title: "View Anime List", style: .default, height: .large, action: {
                self.showAnimeList(friend, fromIndexPath: indexPath)
            }))
            actionSheet.addAction(ManagedActionSheetAction(title: "View Manga List", style: .default, height: .large, action: {
                self.showMangaList(friend, fromIndexPath: indexPath)
            }))
            
            if friends[indexPath.section] == localFriends {
                actionSheet.addAction(ManagedActionSheetAction(title: "Delete Friend", style: .destructive, height: .large, action: {
                    self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
                }))
            }
            
            actionSheet.cancelCompletion = {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            DispatchQueue.main.async {
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FriendsTableViewHeader") as? FriendsTableViewHeader {
            
            let title = friends[section] == MALFriends ? "MAL friends" : "Local friends"
            let rightText = "\(friends[section].count)"
            header.fill(with: title, rightText: rightText)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Database.shared.entitiesTableViewHeaderHeight
    }
    
    // Delete
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return friends[indexPath.section] == localFriends
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return friends[indexPath.section] == localFriends ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            localFriends.remove(at: indexPath.row)
            Database.saveFriends(localFriends)
            if localFriends.isEmpty {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            else {
                tableView.deleteRows(at: [indexPath], with: .fade)
                if let header = tableView.headerView(forSection: indexPath.section) as? FriendsTableViewHeader {
                    header.rightLabel.text = "\(localFriends.count)"
                }
            }
        }
    }
}
