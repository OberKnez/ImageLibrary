//
//  ImageListEndpoint.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

enum ImageListEndpoint {
    case fetchImages(_ request: ImageListApiModel.Request)
}

extension ImageListEndpoint: Requestable {
    
    var method: HTTPMethod {
        switch self {
        case .fetchImages:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .fetchImages:
            return "image_list.json"
        }
    }
    
    var body: Encodable? {
        switch self {
        case .fetchImages:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        
        switch self {
        case .fetchImages:
            return nil
        }
    }
}
