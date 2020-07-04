//
//  SocialNetworkManager.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 31/12/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Social
import TwitterKit

class SocialNetworkManager {
    class func setup() {
        TWTRTwitter.sharedInstance().start(withConsumerKey:Global.twitterConsumerKey, consumerSecret:Global.twitterConsumerSecret)
    }
    
    class func postChanges(_ changes: EntityChanges, fromViewController controller: UIViewController, completion: (() -> Void)? = nil) {
        if Settings.twitterEnabled {
            if let action = requiredAction(forChanges: changes) {
                if Settings.twitterActionsEnabled[action] ?? false {
                    let contentText = content(forChanges: changes, action: action)
                    if !contentText.isEmpty {
                        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                            postWithSLComposer(content: contentText, fromViewController: controller, completion: completion)
                        }
                        else {
                            postWithTwitter(content: contentText, fromViewController: controller, completion: completion)
                        }
                        return
                    }
                }
            }
        }
        
        completion?()
    }
    
    private class func postWithSLComposer(content: String, fromViewController controller: UIViewController, completion: (() -> Void)?) {
        let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composer?.setInitialText(content)
        composer?.completionHandler = { _ in delay(0.4) { completion?() } }
        controller.present(composer!, animated: true, completion: nil)
    }
    
    private class func postWithTwitter(content: String, fromViewController controller: UIViewController, completion: (() -> Void)?) {
        let composer = TWTRComposer()
        composer.setText(content)
        composer.show(from: controller, completion: { _ in delay(0.4) { completion?() } })
    }
    
    class func requiredAction(forChanges changes: EntityChanges) -> Settings.TwitterAction? {
        let isAnime = changes.originalEntity is UserAnime
        if changes.originalEntity.status == .unknown {
            return isAnime ? .addAnime : .addManga
        }
        else if let newStatus = changes.statusChanges {
            if newStatus == .completed && (changes.originalEntity.status != .completed || (!changes.restarting && changes.originalEntity.restarting)) {
                return isAnime ? .completeAnime : .completeManga
            }
            if newStatus == .dropped && changes.originalEntity.status != .dropped {
                return isAnime ? .dropAnime : .dropManga
            }
        }
        
        if let anime = changes as? AnimeChanges {
            if anime.watchedEpisodesChanges != nil {
                return .updateAnime
            }
        }
        else if let manga = changes as? MangaChanges {
            if manga.readVolumesChanges != nil || manga.readChaptersChanges != nil {
                return .updateManga
            }
        }
        return nil
    }
    
    class func content(forChanges changes: EntityChanges, action: Settings.TwitterAction) -> String {
        let linkAndTag = " #iMAL_iOS \(changes.originalEntity.series.malURL)"
        let seriesName = changes.originalEntity.series.name
        
        switch action {
        case .addAnime, .addManga:
            return "I just added \(seriesName) to my \(changes.statusDisplayString) list" + linkAndTag
        case .completeAnime, .completeManga:
            if changes.score > 0 {
                return "I completed \(seriesName) with a score of \(changes.score)" + linkAndTag
            }
            return "I completed \(seriesName)" + linkAndTag
        case .dropAnime, .dropManga:
            return "I dropped \(seriesName)" + linkAndTag
        case .updateAnime:
            if changes.originalEntity.status == .planToWatch && changes.status == .watching {
                return "I started watching \(seriesName)" + linkAndTag
            }
            let anime = changes as! AnimeChanges
            var diff = anime.watchedEpisodes - anime.originalAnime.watchedEpisodes
            if anime.restarting && !anime.originalAnime.restarting {
                diff = anime.watchedEpisodes
            }
            let absoluteCount = "\(anime.watchedEpisodes)" + (anime.originalAnime.animeSeries.episodes > 0 ? "/\(anime.originalAnime.animeSeries.episodes)" : "")
            return "I \(anime.restarting ? "rewatched" : "watched") \(diff) episode\(diff > 1 ? "s" : "") (\(absoluteCount)) of \(seriesName)" + linkAndTag
        case .updateManga:
            if changes.originalEntity.status == .planToWatch && changes.status == .watching {
                return "I started reading \(seriesName)" + linkAndTag
            }
            let manga = changes as! MangaChanges
            
            func tweetMangaChanges(metric: Int, newMetric: Int?, originalMetric: Int, manga: MangaChanges, name: String) -> String? {
                if let newMetric = newMetric, newMetric != originalMetric {
                    var diff = newMetric - originalMetric
                    if manga.restarting && !manga.originalManga.restarting {
                        diff = newMetric
                    }
                    let absoluteCount = "\(newMetric)" + (metric > 0 ? "/\(metric)" : "")
                    return "I \(manga.restarting ? "re-read" : "read") \(diff) \(name)\(diff > 1 ? "s" : "") (\(absoluteCount)) of \(seriesName)" + linkAndTag
                }
                return nil
            }
            
            let volumesTweet = tweetMangaChanges(metric: manga.originalManga.mangaSeries.volumes, newMetric: manga.readVolumesChanges, originalMetric: manga.originalManga.readVolumes, manga: manga, name: "volume")
            let chaptersTweet = tweetMangaChanges(metric: manga.originalManga.mangaSeries.chapters, newMetric: manga.readChaptersChanges, originalMetric: manga.originalManga.readChapters, manga: manga, name: "chapter")
            
            return MangaMetricsRepresentation.chooseAccordingToPreference(manga: manga.originalManga.mangaSeries, volumes: volumesTweet, chapters: chaptersTweet, default: "")
        }
    }
    
    class func alertNoTwitterAccountAvailable(inController controller: UIViewController, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Unable to send tweet", message: "There are no Twitter accounts configured. You can add a Twitter account in Settings.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            openSettingsURL()
            completion?()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion?() }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func openSettingsURL() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
    }
}
