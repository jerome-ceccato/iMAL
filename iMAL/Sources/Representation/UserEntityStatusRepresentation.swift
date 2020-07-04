//
//  UserEntityStatusRepresentation.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit

struct UserEntityStatusRepresentation {
    static func fullStatusAttributedDisplayString(for userEntity: UserEntity, metadata: EntityCellMetadata? = nil) -> NSAttributedString {
        let wantsFullStatus = metadata?.wantsFullStatus ?? false
        let content = NSMutableAttributedString()
        
        if wantsFullStatus {
            let userEntityStatus = userEntity.specialStatus ?? userEntity.statusDisplayString
            let attributedString = NSAttributedString(string: userEntityStatus, attributes: [NSAttributedStringKey.foregroundColor: userEntity.status.colorCode()])
            addSeparatedContent(to: content, next: attributedString)
        }
        else if let status = userEntity.specialStatus {
            addSeparatedContent(to: content, next: status)
        }
        
        addSeparatedContent(to: content, next: userEntity.series.type.displayString)
        if let anime = userEntity as? UserAnime,
            let status = AiringDataRepresentation.userAnimeAiringDataDisplayString(for: anime, statusDisplayOption: .never) {
            addSeparatedContent(to: content, next: status)
        }
        else if !userEntity.series.status.isDone {
            addSeparatedContent(to: content, next: userEntity.series.status.displayString)
        }
        return content
    }
}

private extension UserEntityStatusRepresentation {
    static var regularAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: ThemeManager.currentTheme.airingTime.regular.color]
    }
    static var separatorAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: ThemeManager.currentTheme.airingTime.separator.color]
    }
    
    @discardableResult
    static func addSeparatedContent(to: NSMutableAttributedString, next: NSAttributedString, separator: String = " - ") -> NSMutableAttributedString {
        if !to.string.isEmpty {
            to.append(NSAttributedString(string: separator, attributes: separatorAttributes))
        }
        to.append(next)
        return to
    }
    
    @discardableResult
    static func addSeparatedContent(to: NSMutableAttributedString, next: String, separator: String = " - ") -> NSMutableAttributedString {
        return addSeparatedContent(to: to, next: NSAttributedString(string: next, attributes: regularAttributes), separator: separator)
    }
}
