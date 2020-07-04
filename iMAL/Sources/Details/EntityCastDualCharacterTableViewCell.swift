//
//  EntityCastDualCharacterTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCastDualCharacterTableViewCell: EntityCastBaseTableViewCell {
    func fill(with character: Cast, voiceActor: Cast.VoiceActor) {
        fillContent(imageURL: character.imageURL,
                    main: character.name,
                    subtitle: character.role,
                    position: .left)
        
        fillContent(imageURL: voiceActor.imageURL,
                    main: voiceActor.name,
                    subtitle: voiceActor.language,
                    position: .right)
    }
}
