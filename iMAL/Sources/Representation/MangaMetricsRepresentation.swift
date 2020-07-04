//
//  MangaMetricsRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct MangaMetricsRepresentation {
    static func preferredMetricDisplayString(manga: Manga) -> String {
        let volumesString = (manga.volumes > 0) ? "\(manga.volumes) volume\(manga.volumes > 1 ? "s" : "")" : nil
        let chaptersString = (manga.chapters > 0) ? "\(manga.chapters) chapter\(manga.chapters > 1 ? "s" : "")" : nil
        
        let defaultValue = chooseAccordingToPreference(manga: manga, volumes: "? vol.", chapters: "? ch.", default: "")
        return chooseAccordingToPreference(manga: manga, volumes: volumesString, chapters: chaptersString, default: defaultValue)
    }
    
    static func chooseAccordingToPreference<T>(manga: Manga, volumes: T?, chapters: T?, default defaultValue: T) -> T {
        if Settings.preferredMangaMetric == .volumes || (Settings.preferredMangaMetric == .dynamic && manga.mangaType == .novel) {
            return volumes ?? chapters ?? defaultValue
        }
        else {
            return chapters ?? volumes ?? defaultValue
        }
    }
}
