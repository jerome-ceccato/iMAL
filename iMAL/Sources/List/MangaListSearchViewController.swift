//
//  MangaListSearchViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaListSearchViewController: EntityListSearchViewController {
    
    override var analyticsIdentifier: Analytics.View? {
        return .mangaSearch
    }
    
    override var analyticsEntityType: Analytics.EntityType! {
        return .manga
    }
    
    override var entityName: String {
        return "manga"
    }
    
    override var requiredListKind: EntityKind? {
        return EntityKind.manga
    }
    
    override func apiSearchEntityMethod(terms: String, page: Int? = nil) -> API! {
        return API.searchManga(terms: terms, page: page)
    }
    
    override var cellIdentifier: String {
        return attachedEntityListController.editable ? "EditableMangaTableViewCell" : "MangaTableViewCell"
    }
    
    override var searchCellIdentifier: String {
        return "MangaSearchTableViewCell"
    }
    
    override func fillListEntityCell(_ cell: EntityTableViewCell, item: UserEntity?) {
        if let editableCell = cell as? EditableMangaTableViewCell, attachedEntityListController.editable {
            editableCell.delegate = self
        }
        
        super.fillListEntityCell(cell, item: item)
    }
    
    override func entityIsAlreadyInList(_ entity: Entity) -> Bool {
        return CurrentUser.me.cachedMangaList()?.find(by: entity.identifier) != nil
    }
}

extension MangaListSearchViewController: EditableMangaActionDelegate {
    func mangaDidUpdate(_ changes: MangaChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void) {
        if let delegate = attachedEntityListController as? EditableMangaActionDelegate {
            delegate.mangaDidUpdate(changes, loadingDelegate: loadingDelegate ?? self, completion: completion)
        }
    }
}
