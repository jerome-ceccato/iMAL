//
//  AnimeTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimeTableViewCell: EntityTableViewCell {
    @IBOutlet var episodesLabel: UILabel!
    
    override func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata? = nil) {
        super.fill(withUserEntity: entity, metadata: metadata)
        
        if let anime = entity as? UserAnime {
            episodesLabel.attributedText = UserAnimeRepresentation.attributedEpisodesCounter(for: anime)
        }
    }
}
