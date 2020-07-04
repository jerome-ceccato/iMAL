//
//  UIImage+Color.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 10/09/2016.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

extension UIImage {
    class func image(withColor color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    class func roundedImage(_ image: UIImage, cornerRadius: Int) -> UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: CGFloat(cornerRadius)
            ).addClip()
        image.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
