//
//  EntitySearchTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 16/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EntitySearchTableViewCell: EntityOwnerTableViewCell {
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infosLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 3
        pictureImageView.layer.masksToBounds = true
        
        applyTheme { [unowned self] theme in
            self.pictureImageView.backgroundColor = theme.entity.pictureBackground.color
            self.nameLabel.textColor = theme.entity.name.color
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.cancelImageLoading()
    }
    
    func fill(with entity: Entity) {
        self.entity = entity
        
        pictureImageView.image = nil
        pictureImageView.setImageWithURLString(entity.pictureURL, animated: true, completion: nil)
        
        nameLabel.text = entity.name
        infosLabel.attributedText = makeInfosAttributedString(entity)
    }

    func makeInfosAttributedString(_ entity: Entity) -> NSMutableAttributedString {
        let content = NSMutableAttributedString()

        appendContent(content, string: entity.type.displayString, highlighted: false)
        let score = entity.membersScore.map { $0 > Float.ulpOfOne ? String(format: "%.2f", $0) : "" }
        appendContent(content, string: score, highlighted: true)
        
        return content
    }
    
    func appendContent(_ content: NSMutableAttributedString, string: String?, highlighted: Bool) {
        guard let string = string else { return }
        guard !string.isEmpty else { return }
        
        let regularColor = ThemeManager.currentTheme.entity.label.color
        let hlColor = ThemeManager.currentTheme.entity.score.color
        
        if content.length > 0 {
            content.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.foregroundColor: regularColor]))
        }
        content.append(NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: highlighted ? hlColor : regularColor]))
    }
}
