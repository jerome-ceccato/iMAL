//
//  MangaTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaTableViewCell: EntityTableViewCell, MangaCellActions {
    @IBOutlet var chaptersLabel: UILabel!
    @IBOutlet var volumesLabel: UILabel!
    
    override func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        super.fill(withUserEntity: entity, metadata: metadata)
        
        if let manga = entity as? UserManga {
            let fontSize = estimatedFontSizeForMangaCounters(manga)
            chaptersLabel.attributedText = UserMangaRepresentation.attributedChaptersCounter(for: manga, fontSize: fontSize)
            volumesLabel.attributedText = UserMangaRepresentation.attributedVolumesCounter(for: manga, fontSize: fontSize)
        }
    }
}
