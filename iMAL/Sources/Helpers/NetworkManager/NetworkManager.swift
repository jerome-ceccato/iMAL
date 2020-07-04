//
//  NetworkManager.swift
//  Copyright © 2016 IATGOF. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Pagination {
    public let limit: Int
    public let offset: Int
    public init(limit: Int = 0, offset: Int = 0) {
        self.limit = limit
        self.offset = offset
    }
}

public class NetworkResponseData {
    public enum Format {
        case raw
        case json
    }
    
    var json: JSON! = nil
    var raw: String! = nil
    
    var format: Format
    
    init(json: JSON) {
        self.format = .json
        self.json = json
    }
    
    init(raw: String) {
        self.format = .raw
        self.raw = raw
    }
}

public protocol NetworkManager {
    var host: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var pagination: Pagination? { get }
    var baseParams: [String:AnyObject] { get }
    var requestParams: [String:AnyObject] { get }
    func objectFromResponseData(_ json: NetworkResponseData) -> Any
}

public extension NetworkManager {
    internal func parameters(_ pagination: Pagination?) -> [String:AnyObject] {
        var params = baseParams
        params.mergeInPlace(requestParams)
        if let page = pagination {
            params.mergeInPlace(["limit": page.limit as AnyObject])
            if page.offset > 0 {
                params.mergeInPlace(["offset": page.offset as AnyObject])
            }
        }
        return params
    }
}

internal extension Dictionary {
    mutating func mergeInPlace(_ other: Dictionary) {
        other.forEach() {
            self.updateValue($1, forKey: $0)
        }
    }
    
    func mergeTo(_ other: Dictionary) -> Dictionary {
        var dict = other
        dict.mergeInPlace(self)
        return dict
    }
}
