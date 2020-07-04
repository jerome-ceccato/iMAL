//
//  UIImageView+Network.swift
//  iMAL
//
//  Created by Jerome Ceccato on 09/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {
    func setImageWithURL(_ url: URL) {
        af_setImage(withURL: url)
    }
    
    func setImageWithURLString(_ url: String) {
        if let url = URL(string: url) {
            af_setImage(withURL: url)
        }
    }
    
    func setImageWithURL(_ url: URL, placeholder: UIImage? = nil, animated: Bool = false, animationDuration: TimeInterval = 0.2, completion: ((UIImage?) -> Void)?) {
        af_setImage(withURLRequest: URLRequest(url: url),
                    placeholderImage: placeholder,
                    imageTransition: animated ? .crossDissolve(animationDuration) : .noTransition,
                    runImageTransitionIfCached: false,
                    completion: { response in
                        
                        switch response.result {
                        case .success(let image):
                            completion?(image)
                        case .failure:
                            completion?(nil)
                        }
        })
    }
    
    func setImageWithURLString(_ url: String, placeholder: UIImage? = nil, animated: Bool = false, animationDuration: TimeInterval = 0.2, completion: ((UIImage?) -> Void)?) {
        if let url = URL(string: url) {
            setImageWithURL(url, placeholder: placeholder, animated: animated, animationDuration: animationDuration, completion: completion)
        }
        else {
            completion?(nil)
        }
    }
    
    func cancelImageLoading() {
        af_cancelImageRequest()
    }
}
