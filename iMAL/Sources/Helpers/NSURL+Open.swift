//
//  NSURL+Open.swift
//  iMAL
//
//  Created by Jerome Ceccato on 30/11/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import SafariServices

extension URL {
    func open(in controller: UIViewController) {
        controller.present(SFSafariViewController(url: self), animated: true, completion: nil)
    }
}
