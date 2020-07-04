//
//  EntityCastVoiceActorTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCastVoiceActorTableViewCell: EntityCastBaseTableViewCell {
    func fill(with voiceActor: Cast.VoiceActor) {
        fillContent(imageURL: voiceActor.imageURL,
                    main: voiceActor.name,
                    subtitle: voiceActor.language,
                    position: .right)
    }
}
