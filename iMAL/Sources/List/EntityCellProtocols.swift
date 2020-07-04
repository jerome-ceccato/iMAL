//
//  EntityCellProtocols.swift
//  iMAL
//
//  Created by Jerome Ceccato on 26/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

protocol EntityCellLongPressDelegate: class {
    func didLongPressCell(_ cell: EntityOwnerCell)
}

protocol EditableEntityCellDelegate: class {
    func canEditCell(_ cell: EditableEntityCell) -> Bool
    func lockEditingToCell(_ cell: EditableEntityCell) -> Bool
    func unlockEditing()

    func shouldShowScorePickerForUpdate(cell: EditableEntityCell, currentScore: Int?, completion: @escaping (Int?) -> Void)
}

protocol EntityOwnerCell: class {
    var entity: Entity! { get }
}

protocol EntityCell: EntityOwnerCell {
    func fill(withUserEntity entity: UserEntity, metadata: EntityCellMetadata?)
    var canDisplayEditingControls: Bool { get }
}

protocol EditableEntityCell: class {
    func updateEditingStatus()
}

protocol EditableAnimeActionDelegate: EditableEntityCellDelegate {
    func animeDidUpdate(_ changes: AnimeChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void)
}

protocol EditableAnimeCell: EditableEntityCell {
    var delegate: EditableAnimeActionDelegate? { get set }
}

protocol EditableMangaActionDelegate: EditableEntityCellDelegate {
    func mangaDidUpdate(_ changes: MangaChanges, loadingDelegate: NetworkLoadingController?, completion: @escaping () -> Void)
}

protocol EditableMangaCell: EditableEntityCell {
    var delegate: EditableMangaActionDelegate? { get set }
}

// MARK: - 

struct EntityCellMetadata {
    var highlightedText: String?
    var wantsFullStatus: Bool
    var style: ListDisplayStyle
    
    init(highlightedText: String?, wantsFullStatus: Bool, style: ListDisplayStyle) {
        self.highlightedText = highlightedText
        self.wantsFullStatus = wantsFullStatus
        self.style = style
    }
    
    private func applyAttributes(_ string: NSMutableAttributedString, attributes: [NSAttributedStringKey: AnyObject], content: NSString, range: NSRange) {
        let r = content.range(of: highlightedText ?? "", options: .caseInsensitive, range: range, locale: nil)
        if r.location != NSNotFound {
            string.addAttributes(attributes, range: r)
            
            let nextRange = NSMakeRange(r.location + r.length, content.length - (r.location + r.length))
            applyAttributes(string, attributes: attributes, content: content, range: nextRange)
        }
    }
    
    func attributedString(withHighlightableContent content: String) -> NSAttributedString? {
        let color = ThemeManager.currentTheme.entity.name.color
        let regularAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: color.withAlphaComponent(0.7)]
        let highlightedAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: color]
        
        let attributedContent = NSMutableAttributedString(string: content, attributes: regularAttributes)
        
        applyAttributes(attributedContent, attributes: highlightedAttributes, content: content as NSString, range: NSMakeRange(0, (content as NSString).length))
        return attributedContent
    }
    
    func fullStatus(for entity: UserEntity) -> String {
        var status = entity.specialStatus ?? entity.statusDisplayString
        
        if !entity.series.status.isDone {
            status += " - \(entity.series.status.displayString)"
        }
        
        return status
    }
}
