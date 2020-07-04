//
//  EntityCastStaffTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCastStaffTableViewCell: EntityCastBaseTableViewCell {
    func fill(with staff: Cast) {
        fillContent(imageURL: staff.imageURL,
                    main: staff.name,
                    subtitle: staff.rank,
                    position: .left)
    }
}
