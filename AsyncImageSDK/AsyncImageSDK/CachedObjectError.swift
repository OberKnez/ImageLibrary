//
//  CachedObjectError.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public enum CachedObjectError: Error {
    case objectNotFound
    case canNotCreateObjectFromData
    case dataCouldNotBeCreated
    case objectIsNotStored
    case objectIsNotRetreived
    case objectsAreNotDeleted
    case objectIsNotRemoved
}

extension CachedObjectError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .objectNotFound:
            return "Object was not found among cached objects."
        case .canNotCreateObjectFromData:
            return "Object could not be created from data."
        case .dataCouldNotBeCreated:
            return "Data could not be made from object."
        case .objectIsNotRemoved:
            return "Object is not removed."
        case .objectsAreNotDeleted:
            return "Object are not deleted."
        case .objectIsNotRetreived:
            return "Object is not fetched."
        case .objectIsNotStored:
            return "Object is not stored."
        }
    }
}
