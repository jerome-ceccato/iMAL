//
//  GradientView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 13/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.black.withAlphaComponent(0)
    @IBInspectable var bottomColor: UIColor = UIColor.black

    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addLinearGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    private func addLinearGradient() {
        gradientLayer?.removeFromSuperlayer()
        
        let colors = [topColor.cgColor, bottomColor.cgColor]
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        
        gradient.colors = colors
        layer.insertSublayer(gradient, at: 0)
        
        gradientLayer = gradient
    }
}
