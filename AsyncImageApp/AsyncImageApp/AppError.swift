//
//  AppError.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import AsyncImageSDK

public indirect enum AppError: Error {
    case network(NetworkError)
    case caching(CachedObjectError)
    case unknown(String, title: String? = nil)
}


public extension AppError {
    
    init(error: Error) {
        if let appError = error as? AppError {
            self = appError
        } else if let networkError = error as? NetworkError {
            self = Self.createAppError(networkError: networkError)
        } else {
            self = .unknown(error.localizedDescription)
        }
    }
    
    static func createAppError(networkError: NetworkError) -> AppError {
        switch networkError {
        case .timeOut:
            return .network(.timeOut)
        case .invalidRequest:
            return .network(.invalidRequest)
        case .invalidResponse:
            return .network(.invalidResponse)
        case .networkConnection:
            return .network(.networkConnection)
        case .cancelled:
            return .network(.cancelled)
        case .unknown(let error):
            return .network(.unknown(error))
        }
    }
    
    static func createAppError(cachedError: CachedObjectError) -> AppError {
        switch cachedError {
        case .objectNotFound:
            return .caching(.objectNotFound)
        case .canNotCreateObjectFromData:
            return .caching(.canNotCreateObjectFromData)
        case .dataCouldNotBeCreated:
            return .caching(.dataCouldNotBeCreated)
        case .objectIsNotStored:
            return .caching(.objectIsNotStored)
        case .objectIsNotRetreived:
            return .caching(.objectIsNotRetreived)
        case .objectsAreNotDeleted:
            return .caching(.objectsAreNotDeleted)
        case .objectIsNotRemoved:
            return .caching(.objectIsNotRemoved)
        }
    }
}

public extension AppError {
    var localizedDescription: String {
        switch self {
        case .network(let networkError):
            return networkError.debugDescription
        case .caching(let cachedObjectError):
            return cachedObjectError.debugDescription
        case .unknown(let string, let title):
            return string + " " + (title ?? "")
        }
    }
}


public extension AppError {

    var errorType: String {
        var components: [String] = []
        components.append("\(Self.self)")
        
        switch self {
        case .caching(let error as Any),
             .network(let error as Any),
             .unknown(let error as Any, _):
            components.append("\(type(of: error))")
            components.append("\(error)")
        }
        
        return components.joined(separator: ".")
    }
}
