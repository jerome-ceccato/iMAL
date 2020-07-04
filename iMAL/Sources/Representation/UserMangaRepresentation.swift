//
//  UserMangaRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct UserMangaRepresentation {
    static func attributedChaptersCounter(for userManga: UserManga, fontSize: CGFloat = 17) -> NSAttributedString {
        return UserEntityAttributedRepresentation.attributedCounter(withCurrent: userManga.readChapters, total: userManga.mangaSeries.chapters, prefix: "Ch. ", fontSize: fontSize)
    }
    
    static func attributedVolumesCounter(for userManga: UserManga, fontSize: CGFloat = 17) -> NSAttributedString {
        return UserEntityAttributedRepresentation.attributedCounter(withCurrent: userManga.readVolumes, total: userManga.mangaSeries.volumes, prefix: "Vol. ", fontSize: fontSize)
    }
    
    static func attributedChaptersCounter(for mangaChanges: MangaChanges, fontSize: CGFloat = 17) -> NSAttributedString {
        return UserEntityAttributedRepresentation.attributedCounter(withCurrent: mangaChanges.readChapters, total: mangaChanges.originalManga.mangaSeries.chapters, prefix: "Ch. ", fontSize: fontSize)
    }
    
    static func attributedVolumesCounter(for mangaChanges: MangaChanges, fontSize: CGFloat = 17) -> NSAttributedString {
        return UserEntityAttributedRepresentation.attributedCounter(withCurrent: mangaChanges.readVolumes, total: mangaChanges.originalManga.mangaSeries.volumes, prefix: "Vol. ", fontSize: fontSize)
    }
}
