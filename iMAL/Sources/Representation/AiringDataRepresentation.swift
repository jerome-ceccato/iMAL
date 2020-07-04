//
//  AiringDataRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct AiringDataRepresentation {
    enum StatusDisplayOption {
        case never
        case unlessAiring
        case always
    }
    
    private static func airingDataDisplayString(anime: UserAnime?, series: iMAL.Anime, statusDisplayOption: StatusDisplayOption) -> NSAttributedString? {
        if Settings.airingDatesEnabled, let data = Database.shared.airingAnime?.findByID(series.identifier) {
            let status = NSMutableAttributedString()
            let theme = ThemeManager.currentTheme.airingTime
            
            if let nextEpisode = data.nextEpisode() {
                if nextEpisode.number == 1 {
                    if statusDisplayOption == .always || statusDisplayOption == .unlessAiring {
                        status.append(NSAttributedString(string: "Not Yet Aired", attributes: [NSAttributedStringKey.foregroundColor: theme.regular.color]))
                        status.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.foregroundColor: theme.separator.color]))
                    }
                    status.append(NSAttributedString(string: "\(nextEpisode.localTimeDisplayString())", attributes: [NSAttributedStringKey.foregroundColor: theme.notAiredYet.color]))
                }
                else if let anime = anime, anime.watchedEpisodes + 1 >= nextEpisode.number {
                    if statusDisplayOption == .always {
                        status.append(NSAttributedString(string: "Airing", attributes: [NSAttributedStringKey.foregroundColor: theme.regular.color]))
                        status.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.foregroundColor: theme.separator.color]))
                    }
                    status.append(NSAttributedString(string: "ep. \(nextEpisode.number) \(nextEpisode.localTimeDisplayString(context: .needsSeparator))", attributes: [NSAttributedStringKey.foregroundColor: theme.upToDate.color]))
                }
                else {
                    if statusDisplayOption == .always {
                        status.append(NSAttributedString(string: "Airing", attributes: [NSAttributedStringKey.foregroundColor: theme.regular.color]))
                        status.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.foregroundColor: theme.separator.color]))
                    }
                    status.append(NSAttributedString(string: "\(nextEpisode.number - 1) ep. aired", attributes: [NSAttributedStringKey.foregroundColor: theme.available.color]))
                }
                
                return status
            }
        }
        return nil
    }
    
    static func userAnimeAiringDataDisplayString(for anime: UserAnime, statusDisplayOption: StatusDisplayOption = .always) -> NSAttributedString? {
        return airingDataDisplayString(anime: anime, series: anime.animeSeries, statusDisplayOption: statusDisplayOption)
    }
    
    static func animeAiringDataDisplayString(for series: Anime, statusDisplayOption: StatusDisplayOption = .always) -> NSAttributedString? {
        return airingDataDisplayString(anime: nil, series: series, statusDisplayOption: statusDisplayOption)
    }
}
