//
//  IoCManager.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

final class IoCManager {
    
    static let shared = IoCManager()
    
    private init() {}
    
    func resolve<Key: Codable, Value: Codable>(key: Key.Type, value: Value.Type) -> CacheStorageServiceType where Key: Hashable {
        return CacheStorageService<Key, Value>()
    }
    
}
