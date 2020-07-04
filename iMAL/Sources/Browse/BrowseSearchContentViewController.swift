//
//  BrowseSearchContentViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 30/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseSearchContentViewController: BrowseContentBaseViewController {
    var currentFilters: BrowseFilters? = nil

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
        
        title = "Browse \(entityName)"
    }
    
    override func browseAPI() -> API? {
        return currentFilters.map { API.getBrowseSearch(filters: $0, entityKind: entityKind, page: currentPage) }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseSearchTableViewCell", for: indexPath) as! BrowseSearchTableViewCell
        
        cell.longPressDelegate = self
        cell.fill(with: data[indexPath.row])
        return cell
    }
    
    override func messageForNetworkError(_ error: NSError) -> ErrorCenter.Message? {
        if error.code == 404 {
            let entityName = entityKind == .anime ? "anime" : "manga"
            return ErrorCenter.Message(title: "No \(entityName) found", body: "No \(entityName) match the selected filters.", cancelAction: ErrorCenter.Action(name: "OK", callback: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
        }
        return super.messageForNetworkError(error)
    }
}
