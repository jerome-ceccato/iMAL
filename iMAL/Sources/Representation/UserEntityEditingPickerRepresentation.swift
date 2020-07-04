//
//  UserEntityEditingPickerRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct UserEntityEditingPickerRepresentation {
    static func editingPickerDisplayData(userEntity: UserEntity, forceAbsolute absolute: Bool = false) -> [[String]] {
        if let userAnime = userEntity as? UserAnime {
            return UserAnimeEditingPickerRepresentation.editingPickerDisplayData(userAnime: userAnime, forceAbsolute: absolute)
        }
        else if let userManga = userEntity as? UserManga {
            return UserMangaEditingPickerRepresentation.editingPickerDisplayData(userManga: userManga, forceAbsolute: absolute)
        }
        return []
    }
}

struct UserAnimeEditingPickerRepresentation {
    static func editingPickerDisplayData(userAnime: UserAnime, forceAbsolute absolute: Bool = false) -> [[String]] {
        let maximumEpisodes = userAnime.animeSeries.episodes > 0 ? userAnime.animeSeries.episodes : userAnime.watchedEpisodes + 100
        return [(0 ..< maximumEpisodes + 1).map { ep in
            if !absolute && userAnime.watchedEpisodes > 0 {
                if userAnime.animeSeries.episodes > 0 && ep == userAnime.animeSeries.episodes {
                    return "\(ep) ep. (completed)"
                }
                return String(format: "%d ep. (%+d)", ep, ep - userAnime.watchedEpisodes)
            }
            return "\(ep) ep."
            }]
    }
}

struct UserMangaEditingPickerRepresentation {
    static func editingPickerDisplayData(userManga: UserManga, forceAbsolute absolute: Bool = false) -> [[String]] {
        return [editingPickerDataForValue(userManga.readVolumes, maxValue: userManga.mangaSeries.volumes, suffix: "vol.", absolute: absolute),
                editingPickerDataForValue(userManga.readChapters, maxValue: userManga.mangaSeries.chapters, suffix: "ch.", absolute: absolute)]
    }
    
    private static func editingPickerDataForValue(_ value: Int, maxValue: Int, suffix: String, absolute: Bool) -> [String] {
        let maximumValues = maxValue > 0 ? maxValue : value + 100
        return (0 ..< maximumValues + 1).map { v in
            if !absolute && value > 0 {
                return String(format: "%d \(suffix) (%+d)", v, v - value)
            }
            return "\(v) \(suffix)"
        }
    }
}
