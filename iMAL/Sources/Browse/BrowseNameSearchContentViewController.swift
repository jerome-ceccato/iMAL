//
//  BrowseNameSearchContentViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/09/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseNameSearchContentViewController: BrowseContentBaseViewController {
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let entityName: String = {
            switch entityKind! {
            case .anime:
                return "Anime"
            case .manga:
                return "Manga"
            }
        }()
        
        title = "Search \(entityName)"
        
        applyTheme { [unowned self] theme in
            self.toolbar.barStyle = theme.global.bars.style.barStyle
            self.toolbar.tintColor = theme.global.activeTint.color
            self.toolbar.backgroundColor = theme.picker.background.color
            self.toolbar.barTintColor = theme.global.bars.background.color

            self.searchBar.barTintColor = theme.global.viewBackground.color
            self.searchBar.tintColor = theme.global.keyboardIndicator.color
            self.searchBar.backgroundColor = nil
            self.searchBar.keyboardAppearance = theme.global.keyboardStyle.style
            self.searchBar.barStyle = theme.global.bars.style.barStyle
            if #available(iOS 11, *) {} else {
                self.searchBar.setSearchFieldTextColor(theme.global.bars.title.color)
            }
        }
        
        if #available(iOS 11, *) {
            // The flexible space is needed before iOS 11 otherwise the searchBar is too large
            // If added in viewDidLoad it does not work
            // In iOS 11, if the flexible space is there, the searchbar doesn't scale on iPad
            toolbar.items = [toolbar.items!.first!]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "UITableViewController" {
            tableViewController.tableView.contentInset.top += searchBar.bounds.height
            tableViewController.tableView.scrollIndicatorInsets.top += searchBar.bounds.height
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (searchBar.text?.isEmpty ?? true) || data.isEmpty {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func browseAPI() -> API? {
        if let terms = searchBar.text, !terms.isEmpty {
            switch entityKind! {
            case .anime:
                return API.searchAnime(terms: terms, page: currentPage)
            case .manga:
                return API.searchManga(terms: terms, page: currentPage)
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseSearchTableViewCell", for: indexPath) as! BrowseSearchTableViewCell
        
        cell.longPressDelegate = self
        cell.fill(with: data[indexPath.row])
        return cell
    }
}

extension BrowseNameSearchContentViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if 1 ..< 3 ~= (searchBar.text ?? "").count {
            let alert = UIAlertController(title: nil, message: "You need to type at least 3 characters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                searchBar.becomeFirstResponder()
            }))
            present(alert, animated: true, completion: nil)
        }
        else {
            clearReload()
        }
    }
}
