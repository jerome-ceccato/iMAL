//
//  UserAnimeRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct UserAnimeRepresentation {
    static func attributedEpisodesCounter(for userAnime: UserAnime) -> NSAttributedString {
        return UserEntityAttributedRepresentation.attributedCounter(withCurrent: userAnime.watchedEpisodes, total: userAnime.animeSeries.episodes, suffix: " ep.")
    }
    
    static func attributedEpisodesCounter(for animeChanges: AnimeChanges) -> NSAttributedString {
        return UserEntityAttributedRepresentation.attributedCounter(withCurrent: animeChanges.watchedEpisodes, total: animeChanges.originalAnime.animeSeries.episodes, suffix: " ep.")
    }
}
