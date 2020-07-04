//
//  CircleView.swift
//
//  Created by Jérôme Ceccato on 13/01/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

open class CircleView: UIView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = bounds.height / 2.0
        layer.masksToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }
}
