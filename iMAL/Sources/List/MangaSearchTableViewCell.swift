//
//  MangaSearchTableViewCell.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class MangaSearchTableViewCell: EntitySearchTableViewCell {
    override func makeInfosAttributedString(_ entity: Entity) -> NSMutableAttributedString {
        let content = super.makeInfosAttributedString(entity)
        
        if let manga = entity as? Manga {
            appendContent(content, string: manga.classification, highlighted: false)
            
            let metrics = MangaMetricsRepresentation.preferredMetricDisplayString(manga: manga)
            if !metrics.isEmpty {
                appendContent(content, string: metrics, highlighted: false)
            }
        }
        return content
    }
}
