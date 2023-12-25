//
//  HTTPMethod.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}
