//
//  UIView+SuccessToast.swift
//  iMAL
//
//  Created by Jerome Ceccato on 09/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Toast_Swift

extension UIView {
    func makeSuccessToast(_ completion: (() -> Void)? = nil) {
        let successImage = #imageLiteral(resourceName: "success").tinted(with: ToastManager.shared.style.titleColor)
        
        makeToast(nil, duration: 0.3, position: .center, image: successImage)
        if let completion = completion {
            delay(0.5) {
                completion()
            }
        }
    }
}
