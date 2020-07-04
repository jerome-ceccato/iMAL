//
//  ExtendedNetworkManager.swift
//  iMAL
//
//  Created by Jerome Ceccato on 20/07/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public let ExtendedNetworkManagerInternalErrorDomain: String = "NetworkManager Internal error"
public let ExtendedNetworkManagerHTTPErrorDomain: String = "NetworkManager HTTP error"
public let ExtendedNetworkManagerEncodingErrorDomain: String = "NetworkManager Encoding error"
public let ExtendedNetworkManagerInternalErrorCode: Int = 1

private var Manager : Alamofire.SessionManager = Alamofire.SessionManager.default

public protocol ExtendedNetworkManager: NetworkManager {
    func request<T>(context: NetworkManagerContext, loadingDelegate: NetworkLoading?, pagination: Pagination?, completion: @escaping (Bool, T?) -> Void) -> NetworkRequestOperation
    func request(context: NetworkManagerContext, loadingDelegate: NetworkLoading?, pagination: Pagination?, completion: ((Bool) -> Void)?) -> NetworkRequestOperation
    
    var dataFormat: NetworkResponseData.Format { get }
    
    var requestHeaders: [String:String] { get }
    var parameterEncoding: Alamofire.ParameterEncoding { get }
    
    func errorFromResponse(_ response: HTTPURLResponse, data: NetworkResponseData) -> NSError?
    
    func authorizationTokenFromResponse(_ response: HTTPURLResponse, data: NetworkResponseData) -> String?
    func shouldInvalidateAuthorizationTokenAndRestartRequest(response: HTTPURLResponse, data: NetworkResponseData) -> Bool
    
    var requiresAuthentication: Bool { get }
    var isAuthenticationCall: Bool { get }
}

public extension ExtendedNetworkManager {
    
    private func completeRequestWithError<T>(_ error: NSError?, data: T?, operation: NetworkRequestOperation, loadingDelegate: NetworkLoading?, completion: @escaping (Bool, T?) -> Void) {
        DispatchQueue.main.async {
            if let error = error {
                if let loadingDelegate = loadingDelegate {
                    loadingDelegate.stopLoading(operation, withError: error) {
                        completion(false, nil)
                    }
                }
                else {
                    completion(false, nil)
                }
            }
            else {
                loadingDelegate?.stopLoading(operation)
                completion(true, data)
            }
        }
    }
    
    func fullURL() -> String {
        return host.hasSuffix("/") ? host + path : host + "/" + path
    }
    
    private func dataFromResponse(data: Data) -> NetworkResponseData {
        switch dataFormat {
        case .json:
            let jsonData = try? JSON(data: data)
            return NetworkResponseData(json: jsonData ?? JSON(NSNull()))
        case .raw:
            return NetworkResponseData(raw: String(data: data, encoding: .utf8) ?? "")
        }
    }
    
    private func startRequest<T>(_ request: DataRequest, operation: NetworkRequestOperation, context: NetworkManagerContext = NetworkManagerContext.currentContext, loadingDelegate: NetworkLoading? = nil, pagination: Pagination? = nil, completion: @escaping (Bool, T?) -> Void) {
        request.responseData { response in
            
            DispatchQueue.global().async {
                context.logResponse(response)
                
                switch response.result {
                case .success(let data):

                    let responseData = self.dataFromResponse(data: data)
                    
                    if let urlResponse = response.response {
                        if self.shouldInvalidateAuthorizationTokenAndRestartRequest(response: urlResponse, data: responseData) {
                            context.sessionToken = nil
                            loadingDelegate?.stopLoading(operation)
                            _ = self.request(context: context, loadingDelegate: loadingDelegate, pagination: pagination, completion: completion)
                            return
                        }
                        
                        if let error = self.errorFromResponse(urlResponse, data: responseData) {
                            self.completeRequestWithError(error, data: nil, operation: operation, loadingDelegate: loadingDelegate, completion: completion)
                            return
                        }
                        
                        if let token = self.authorizationTokenFromResponse(urlResponse, data: responseData) {
                            context.sessionToken = token
                        }
                    }
                    
                    guard let object = self.objectFromResponseData(responseData) as? T else {
                        let error = NSError(domain: ExtendedNetworkManagerInternalErrorDomain, code: ExtendedNetworkManagerInternalErrorCode, userInfo: [NSLocalizedDescriptionKey: "\(T.self) model instantiation error"])
                        self.completeRequestWithError(error, data: nil, operation: operation, loadingDelegate: loadingDelegate, completion: completion)
                        return
                    }
                    
                    self.completeRequestWithError(nil, data: object, operation: operation, loadingDelegate: loadingDelegate, completion: completion)
                    
                case .failure(let error):
                    self.completeRequestWithError(error as NSError?, data: nil, operation: operation, loadingDelegate: loadingDelegate, completion: completion)
                }
            }
        }
    }

    @discardableResult
    func request<T>(context: NetworkManagerContext = NetworkManagerContext.currentContext, loadingDelegate: NetworkLoading? = nil, pagination: Pagination? = nil, completion: @escaping (Bool, T?) -> Void) -> NetworkRequestOperation {
        
        let operation = NetworkRequestOperation(endpoint: self)
        
        operation.startOperationHandler = { [weak operation] in
            guard let operation = operation else {
                return
            }
            
            let headers: HTTPHeaders = self.requiresAuthentication ? self.requestHeaders.mergeTo(context.authorizationHeaders()) : self.requestHeaders
            let request = Manager.request(self.fullURL(),
                                          method: self.method,
                                          parameters: self.parameters(pagination),
                                          encoding: self.parameterEncoding,
                                          headers: headers)
            
            operation.request = request
            context.logRequest(request)
            loadingDelegate?.startLoading(operation)
            
            self.startRequest(request, operation: operation, context: context, loadingDelegate: loadingDelegate, pagination: pagination, completion: completion)
        }
        
        operation.startOperationHandler!()
        return operation
    }
    
    @discardableResult
    func request(context: NetworkManagerContext = NetworkManagerContext.currentContext, loadingDelegate: NetworkLoading? = nil, pagination: Pagination? = nil, completion: ((Bool) -> Void)? = nil) -> NetworkRequestOperation {
        return request(context: context, loadingDelegate: loadingDelegate, pagination: pagination) { (success: Bool, _: Any?) in
            if let completion = completion {
                completion(success)
            }
        }
    }

    func errorFromResponse(_ response: HTTPURLResponse, data: NetworkResponseData) -> NSError? {
        guard 100 ... 399 ~= response.statusCode else {
            var message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            if data.format == .json, let newMessage = data.json["message"].string {
                message = newMessage
            }
            else if data.format == .raw, let newMessage = data.raw {
                message = newMessage
            }
            return NSError(domain: ExtendedNetworkManagerHTTPErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        return nil
    }
}

public extension ExtendedNetworkManager {
    var pagination: Pagination? {
        return nil
    }
    
    var baseParams: [String:AnyObject] {
        return [:]
    }
    
    var requestParams: [String:AnyObject] {
        return [:]
    }
    
    func objectFromResponseData(_ data: NetworkResponseData) -> Any {
        return data
    }
    
    var requestHeaders: [String:String] {
        return [:]
    }
    
    var requiresAuthentication: Bool {
        return true
    }
    
    var isAuthenticationCall: Bool {
        return false
    }

    func authorizationTokenFromResponse(_ response: HTTPURLResponse, data: NetworkResponseData) -> String? {
        return nil
    }
    
    func shouldInvalidateAuthorizationTokenAndRestartRequest(response: HTTPURLResponse, data: NetworkResponseData) -> Bool {
        return false
    }
    
    var parameterEncoding: Alamofire.ParameterEncoding {
        return URLEncoding.default
    }
}

public extension ExtendedNetworkManager {
    func methodAsString() -> String {
        switch method {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        default:
            return ""
        }
    }
}
