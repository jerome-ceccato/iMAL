//
//  EntityCastCharacterTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCastCharacterTableViewCell: EntityCastBaseTableViewCell {
    func fill(with character: Cast) {
        fillContent(imageURL: character.imageURL,
                    main: character.name,
                    subtitle: character.role,
                    position: .left)
    }
}
