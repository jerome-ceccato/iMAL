//
//  NetworkLoading.swift
//  iMAL
//
//  Created by Jerome Ceccato on 20/07/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Alamofire

public class NetworkRequestOperation {
    var request: Request? = nil
    var endpoint: ExtendedNetworkManager? = nil
    var startOperationHandler: (() -> Void)? = nil

    init(request: Request? = nil, endpoint: ExtendedNetworkManager? = nil) {
        self.request = request
        self.endpoint = endpoint
    }

    var resource: String? {
        return endpoint.map { "\($0.methodAsString()) \($0.path) \($0.requestParams)" }
    }
    
    func retry() {
        startOperationHandler?()
    }
    
    func cancel() {
        request?.cancel()
    }
}

public protocol NetworkLoading {
    func startLoading(_ operation: NetworkRequestOperation)
    func stopLoading(_ operation: NetworkRequestOperation)
    func stopLoading(_ operation: NetworkRequestOperation, withError error: NSError, completion: @escaping () -> Void)
}
