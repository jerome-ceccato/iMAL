//
//  API.swift
//  iMAL
//
//  Created by Jerome Ceccato on 21/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public let APIErrorDomain: String = "iMAL API error"
public let APIInvalidEntityErrorCode: Int = 1


enum API: ExtendedNetworkManager {
    case verifyCredentials
    
    // -- Anime
    
    case getAnimeList(username: String)
    case getAnimeDetails(animeID: Int)
    case getAnimePictures(animeID: Int)
    
    case updateAnime(changes: AnimeChanges)
    case addAnime(values: AnimeChanges)
    case deleteAnime(anime: Anime)
    
    case searchAnime(terms: String, page: Int?)
    
    case getAnimeReviews(anime: Anime, page: Int)
    case getAnimeRecommendations(anime: Anime)
    case getAnimeCast(anime: Anime)
    
    case getEpisodes(anime: Anime, page: Int)
    case getAnimeSchedule
    
    // -- Manga
    
    case getMangaList(username: String)
    case getMangaDetails(mangaID: Int)
    case getMangaPictures(mangaID: Int)
    
    case updateManga(changes: MangaChanges)
    case addManga(values: MangaChanges)
    case deleteManga(manga: Manga)
    
    case searchManga(terms: String, page: Int?)
    
    case getMangaReviews(manga: Manga, page: Int)
    case getMangaRecommendations(manga: Manga)
    case getMangaCast(manga: Manga)
    
    // -- Global
    
    case getFriends(username: String)
    case getAvatarURL(username: String)
    
    case getBrowseContent(contentKind: BrowseData.Section.Kind, entityKind: EntityKind, page: Int)
    case getBrowseSearch(filters: BrowseFilters, entityKind: EntityKind, page: Int)
    
    case getPeople(identifier: Int)
    
    // -- Custom
    
    case systemMessages(lastID: Int)
    case airingAnime
    case browseLanding
}

extension API {
    var host: String {
        switch self {
        case .systemMessages, .airingAnime, .browseLanding:
            return Global.customAPIURL
        case .verifyCredentials, .addAnime, .addManga, .updateAnime, .updateManga, .deleteAnime, .deleteManga:
            return "https://myanimelist.net/api"
        default:
            return Global.privateAPIURL
        }
    }

    var path: String {
        switch self {
        case .verifyCredentials:
            return "account/verify_credentials.xml"
            
        case .addAnime(let values):
            return "animelist/add/\(values.originalEntity.series.identifier).xml"
        case .updateAnime(let changes):
            return "animelist/update/\(changes.originalEntity.series.identifier).xml"
        case .deleteAnime(let anime):
            return "animelist/delete/\(anime.identifier).xml"

        case .addManga(let values):
            return "mangalist/add/\(values.originalEntity.series.identifier).xml"
        case .updateManga(let changes):
            return "mangalist/update/\(changes.originalEntity.series.identifier).xml"
        case .deleteManga(let manga):
            return "mangalist/delete/\(manga.identifier).xml"

        case .getAnimeList(let username):
            return "animelist/\(username.trimmingCharacters(in: .whitespaces))"
        case .getAnimeDetails(let animeID):
            return "anime/\(animeID)"
        case .getAnimePictures(let animeID):
            return "anime/\(animeID)/pics"
        case .searchAnime:
            return "anime/search"
        case .getEpisodes(let anime, _):
            return "anime/episodes/\(anime.identifier)"
        case .getAnimeReviews(let anime, _):
            return "anime/reviews/\(anime.identifier)"
        case .getAnimeRecommendations(let anime):
            return "anime/recs/\(anime.identifier)"
        case .getAnimeCast(let anime):
            return "anime/cast/\(anime.identifier)"
        case .getAnimeSchedule:
            return "anime/schedule"

        case .getMangaList(let username):
            return "mangalist/\(username.trimmingCharacters(in: .whitespaces))"
        case .getMangaDetails(let mangaID):
            return "manga/\(mangaID)"
        case .getMangaPictures(let mangaID):
            return "manga/\(mangaID)/pics"
        case .searchManga:
            return "manga/search"
        case .getMangaReviews(let manga, _):
            return "manga/reviews/\(manga.identifier)"
        case .getMangaRecommendations(let manga):
            return "manga/recs/\(manga.identifier)"
        case .getMangaCast(let manga):
            return "manga/cast/\(manga.identifier)"
            
        case .getFriends(let username):
            return "friends/\(username.trimmingCharacters(in: .whitespaces))"
        case .getAvatarURL(let username):
            return "profile/\(username.trimmingCharacters(in: .whitespaces))"
        case .getBrowseContent(let contentKind, let entityKind, _):
            let entityStrings: [EntityKind: String] = [.anime: "anime", .manga: "manga"]
            let contentStrings: [BrowseData.Section.Kind: String] = [.top: "top", .popular: "popular", .upcoming: "upcoming", .justAdded: "just_added"]
            return "\(entityStrings[entityKind]!)/\(contentStrings[contentKind]!)"
        case .getBrowseSearch(_, let entityKind, _):
            let entityStrings: [EntityKind: String] = [.anime: "anime", .manga: "manga"]
            return "\(entityStrings[entityKind]!)/browse"
        case .getPeople(let identifier):
            return "people/\(identifier)"

            
        case .systemMessages:
            return "news/news.php"
        case .airingAnime:
            return "airing.json"
        case .browseLanding:
            return "landing.json"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .verifyCredentials, .getAnimeList, .getAnimeDetails, .searchAnime, .getMangaList, .getMangaDetails, .searchManga,
             .getFriends, .getAvatarURL, .getEpisodes, .getAnimeReviews, .getMangaReviews, .getAnimeRecommendations,
             .getMangaRecommendations, .getAnimeCast, .getMangaCast, .getBrowseContent, .getAnimeSchedule,
             .getBrowseSearch, .getAnimePictures, .getMangaPictures, .getPeople:
            return .get
        case .addAnime, .addManga, .updateAnime, .updateManga:
            return .post
        case .deleteAnime, .deleteManga:
            return .delete
            
        case .systemMessages, .airingAnime, .browseLanding:
            return .get
        }
    }
    
    var dataFormat: NetworkResponseData.Format {
        switch self {
        case .verifyCredentials, .addAnime, .addManga, .updateAnime, .updateManga, .deleteAnime, .deleteManga:
            return .raw
        default:
            return .json
        }
    }
    
    var requestParams: [String: AnyObject] {
        switch self {
        
        case .addAnime(let values):
            return ["data": values.asXMLString() as AnyObject]
        case .updateAnime(let changes):
            return ["data": changes.asXMLString() as AnyObject]
            
        case .addManga(let values):
            return ["data": values.asXMLString() as AnyObject]
        case .updateManga(let changes):
            return ["data": changes.asXMLString() as AnyObject]
        
        
        case .searchAnime(let terms, let page):
            return ["q": terms as AnyObject, "page": page as AnyObject? ?? 1 as AnyObject]
        case .getEpisodes(_, let page):
            return ["page": (page + 1) as AnyObject]
        case .getAnimeReviews(_, let page):
            return ["page": (page + 1) as AnyObject]
            
        case .searchManga(let terms, let page):
            return ["q": terms as AnyObject, "page": page as AnyObject? ?? 1 as AnyObject]
        case .getMangaReviews(_, let page):
            return ["page": (page + 1) as AnyObject]
            
        case .getBrowseContent(_, _, let page):
            return ["page": (page + 1) as AnyObject]
        case .getBrowseSearch(let filters, _, let page):
            return filters.toParameters() + ["page": (page + 1) as AnyObject]

        case .systemMessages(let lastID):
            return ["from": lastID as AnyObject]
        default:
            return [:]
        }
    }
    
    func objectFromResponseData(_ data: NetworkResponseData) -> Any {
        switch data.format {
        case .json:
            let json = data.json!
            switch self {
            case .getAnimeList:
                return AnimeList(json: json)
            case .getAnimeDetails:
                return Anime(json: json)
            case .getAnimePictures:
                return json.arrayValue.map { $0.stringValue }
            case .searchAnime:
                return json.arrayValue.map { Anime(json: $0) } as [Entity]
            case .getEpisodes:
                return json.arrayValue.map { Episode(json: $0) }
            case .getAnimeReviews:
                return json.arrayValue.map { AnimeReview(json: $0) } as [Review]
            case .getAnimeRecommendations:
                return json.arrayValue.map { Recommendation(json: $0, kind: .anime) }
            case .getAnimeCast:
                var result = [String: [Cast]]()
                json.dictionaryValue.forEach({ result[$0.key] = $0.value.arrayValue.map { Cast(json: $0) }})
                return result
            case .getAnimeSchedule:
                return AnimeSchedule(json: json)
                
            case .getMangaList:
                return MangaList(json: json)
            case .getMangaDetails:
                return Manga(json: json)
            case .getMangaPictures:
                return json.arrayValue.map { $0.stringValue }
            case .searchManga:
                return json.arrayValue.map { Manga(json: $0) } as [Entity]
            case .getMangaReviews:
                return json.arrayValue.map { MangaReview(json: $0) } as [Review]
            case .getMangaRecommendations:
                return json.arrayValue.map { Recommendation(json: $0, kind: .manga) }
            case .getMangaCast:
                var result = [String: [Cast]]()
                json.dictionaryValue.forEach({ result[$0.key] = $0.value.arrayValue.map { Cast(json: $0) }})
                return result
                
            case .getFriends:
                return json.arrayValue.map { Friend(json: $0) }
            case .getAvatarURL:
                return json["avatar_url"].string as Any
            case .getBrowseContent(_, let entityKind, _):
                switch entityKind {
                case .anime:
                    return json.arrayValue.map { Anime(json: $0) } as [Entity]
                case .manga:
                    return json.arrayValue.map { Manga(json: $0) } as [Entity]
                }
            case .getBrowseSearch(_, let entityKind, _):
                switch entityKind {
                case .anime:
                    return json.arrayValue.map { Anime(json: $0) } as [Entity]
                case .manga:
                    return json.arrayValue.map { Manga(json: $0) } as [Entity]
                }
            case .getPeople:
                return People(json: json)
                
            case .systemMessages:
                return json.arrayValue.map { CommunicationMessage(json: $0) }
            case .airingAnime:
                return json
            case .browseLanding:
                return BrowseData(json: json)
            default:
                return json
            }
        case .raw:
            return data.raw!
        }
    }
    
    var requiresAuthentication: Bool {
        switch self {
        case .verifyCredentials:
            return true
        case .addAnime, .addManga, .updateAnime, .updateManga, .deleteAnime, .deleteManga:
            return true
        default:
            return false
        }
    }
    
    var isAuthenticationCall: Bool {
        switch self {
        case .verifyCredentials:
            return true
        default:
            return false
        }
    }
}

extension API {
    static var registrationURL: URL! {
        return URL(string: "http://myanimelist.net/register.php")
    }
    
    static var editPasswordURL: URL! {
        return URL(string: "http://myanimelist.net/editprofile.php?go=myoptions")
    }
    
    static var loginURL: URL! {
        return URL(string: "https://myanimelist.net/login.php")
    }
}
