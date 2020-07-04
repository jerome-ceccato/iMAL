//
//  RoundCornersView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class RoundCornersView: UIView {
    @IBInspectable var cornerRadii: CGSize = CGSize(width: 4, height: 4)
    @IBInspectable var corners: UIRectCorner = [.topLeft] {
        didSet {
            applyRoundCorners()
        }
    }
    
    override func awakeFromNib() {
        applyRoundCorners()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundCorners()
    }
    
    private func applyRoundCorners() {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: cornerRadii)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
