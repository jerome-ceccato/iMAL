//
//  AnimeListSearchViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 12/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimeListSearchViewController: EntityListSearchViewController {
    override var analyticsIdentifier: Analytics.View? {
        return .animeSearch
    }
    
    override var analyticsEntityType: Analytics.EntityType! {
        return .anime
    }
    
    override var entityName: String {
        return "anime"
    }
    
    override var requiredListKind: EntityKind? {
        return EntityKind.anime
    }
    
    override func apiSearchEntityMethod(terms: String, page: Int? = nil) -> API! {
        return API.searchAnime(terms: terms, page: page)
    }
    
    override var cellIdentifier: String {
        return attachedEntityListController.editable ? "EditableAnimeTableViewCell" : "AnimeTableViewCell"
    }
    
    override var searchCellIdentifier: String {
        return "AnimeSearchTableViewCell"
    }

    override func fillListEntityCell(_ cell: EntityTableViewCell, item: UserEntity?) {
        if let editableCell = cell as? EditableAnimeTableViewCell, attachedEntityListController.editable {
            editableCell.delegate = self
        }
        
        super.fillListEntityCell(cell, item: item)
    }
    
    override func entityIsAlreadyInList(_ entity: Entity) -> Bool {
        return CurrentUser.me.cachedAnimeList()?.find(by: entity.identifier) != nil
    }
}

extension AnimeListSearchViewController: EditableAnimeActionDelegate {
    func animeDidUpdate(_ changes: AnimeChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void) {
        if let delegate = attachedEntityListController as? EditableAnimeActionDelegate {
            delegate.animeDidUpdate(changes, loadingDelegate: loadingDelegate ?? self, completion: completion)
        }
    }
}
