//
//  NetworkManagerContext.swift
//  iMAL
//
//  Created by Jerome Ceccato on 20/07/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

open class NetworkManagerContext {
    public static let currentContext = NetworkManagerContext()
    
    open var logLevel = LogLevel.none
    
    open var sessionToken: String?
    open var credentials: Credentials?

    public struct Credentials {
        public var username: String
        public var password: String
        
        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }
    
    public enum LogLevel {
        case none
        case simple
        case detailed
    }
}

// MARK: - Auth
public extension NetworkManagerContext {
    public func authorizationHeaders() -> [String: String] {
        if let token = sessionToken {
            return ["Authorization": "Bearer \(token)"]
        }
        else if let credentials = credentials {
            if let data = "\(credentials.username):\(credentials.password)".data(using: String.Encoding.utf8) {
                return ["Authorization": "Basic \(data.base64EncodedString(options: []))"]
            }
        }
        return [:]
    }
}

// MARK: - Log
public extension NetworkManagerContext {
    public func logRequest(_ request: Request) {
        switch logLevel {
        case .simple:
            if let requestURL = request.request?.url?.absoluteString {
                print(requestURL)
            }
        case .detailed:
            debugPrint(request)
        default:
            break
        }
    }
    
    public func logResponse(_ response: Alamofire.DataResponse<Data>) {
        switch logLevel {
        case .simple:
            switch response.result {
            case .success(let valueData):
                if let value = try? JSON(data: valueData) {
                    if let dict = value.dictionaryObject {
                        print("Success (Dictionary with keys: \(Array(dict.keys)))")
                    }
                    else if let array = value.arrayObject {
                        print("Success (Array of \(array.count) objects)")
                    }
                    else {
                        print("Success (\(type(of: value)))")
                    }
                }
                else {
                    print("Unable to build JSON from value")
                }
            case .failure(let error):
                print("Failure (\(error))")
            }
        case .detailed:
            switch response.result {
            case .success(let valueData):
                if let value = try? JSON(data: valueData) {
                    print("Success")
                    if let urlResponse = response.response {
                        debugPrint(urlResponse)
                    }
                    if let dict = value.dictionaryObject {
                        print("\(dict)")
                    }
                    else if let array = value.arrayObject {
                        print("\(array)")
                    }
                    else {
                        print("\(value)")
                    }
                }
                else {
                    print("Unable to build JSON from value")
                }
            case .failure(let error):
                print("Failure (\(error))")
            }
        default:
            break
        }
    }
    
    public func logWarning(_ string: String) {
        if logLevel == .detailed {
            print("Warning: \(string)")
        }
    }
}
