//
//  TemplateImageView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class TemplateImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        image = image?.withRenderingMode(.alwaysTemplate)
    }
}
