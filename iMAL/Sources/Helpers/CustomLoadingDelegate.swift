//
//  CustomLoadingDelegate.swift
//  iMAL
//
//  Created by Jerome Ceccato on 23/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class CustomLoadingDelegate: NetworkLoading {
    var handler: (NetworkRequestOperation, Bool, NSError?) -> Void
    
    init(handler: @escaping (NetworkRequestOperation, Bool, NSError?) -> Void) {
        self.handler = handler
    }
    
    func startLoading(_ operation: NetworkRequestOperation) {
        handler(operation, true, nil)
    }
    
    func stopLoading(_ operation: NetworkRequestOperation) {
        handler(operation, false, nil)
    }
    
    func stopLoading(_ operation: NetworkRequestOperation, withError error: NSError, completion: @escaping () -> Void) {
        handler(operation, false, error)
        completion()
    }
}
