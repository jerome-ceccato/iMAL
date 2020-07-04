//
//  BrowseContentViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 14/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseContentViewController: BrowseContentBaseViewController {
    var contentKind: BrowseData.Section.Kind!

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
        
        switch contentKind! {
        case .top:
            title = "Top \(entityName)"
        case .popular:
            title = "Popular \(entityName)"
        case .upcoming:
            title = "Upcoming \(entityName)"
        case .justAdded:
            title = "Just Added"
        default:
            title = ""
        }
    }
   
    override func browseAPI() -> API? {
        return API.getBrowseContent(contentKind: contentKind, entityKind: entityKind, page: currentPage)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseContentTableViewCell", for: indexPath) as! BrowseContentTableViewCell
        
        cell.longPressDelegate = self
        cell.fill(with: data[indexPath.row], contentKind: contentKind, indexPath: indexPath)
        return cell
    }
}
