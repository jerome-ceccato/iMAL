//
//  AnimeSearchTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 17/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class AnimeSearchTableViewCell: EntitySearchTableViewCell {
    override func makeInfosAttributedString(_ entity: Entity) -> NSMutableAttributedString {
        let content = super.makeInfosAttributedString(entity)
        
        if let anime = entity as? Anime {
            appendContent(content, string: anime.classification, highlighted: false)
            if anime.episodes > 0 {
                appendContent(content, string: "\(anime.episodes) episode\(anime.episodes > 1 ? "s" : "")", highlighted: false)
            }
        }
        return content
    }
}
