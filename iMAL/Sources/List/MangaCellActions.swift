//
//  MangaCellActions.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

protocol MangaCellActions: EntityCell {

}

extension MangaCellActions {
    // Trying to render attributed strings to find the optimal size is extremely inefficient and lags the display, so we try to guess manually
    func estimatedFontSizeForMangaCounters(_ manga: UserManga) -> CGFloat {
        if !canDisplayEditingControls || (manga.sortingStatus != .watching) || AppDelegate.shared.viewPortSize.width > 320 {
            return 17
        }
        
        let chaptersCharacters = ilog10(manga.readChapters) + (manga.mangaSeries.chapters > 0 ? ilog10(manga.mangaSeries.chapters) + 2 : 0)
        let volumesCharacters = ilog10(manga.readVolumes) + (manga.mangaSeries.volumes > 0 ? ilog10(manga.mangaSeries.volumes) + 2 : 0)
        let totalCharacters = chaptersCharacters + volumesCharacters
        
        return CGFloat(min(17, max(10, 26 - totalCharacters)))
    }
    
    func ilog10(_ a: Int) -> Int {
        var inc = 1, a = a
        while a >= 10 {
            inc += 1
            a /= 10
        }
        return inc
    }
}
