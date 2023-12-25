//
//  CacheStorageService.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import UIKit
import Combine

class CacheStorageService<Key: Codable, Value: Codable>: CacheStorageServiceType where Key: Hashable {
    
    let cache = CacheStorage<Key, Value>()
    private let dispatchQueue = DispatchQueue(label: "QueueCacheStorage", qos: .userInitiated)
    
    func store(_ object: Codable, for key: Codable, expirationInSeconds: Int?) {
        guard let object = object as? Value, let key = key as? Key else { return }
        dispatchQueue.async { [weak self] in
            try? self?.cache.insert(object, forKey: key, expiryInterval: expirationInSeconds)
        }
    }
    
    func getCachedObject(for key: Codable) -> Future<ReturnedType<Codable>, Never> {
        return Future { [weak self] promise in
            self?.dispatchQueue.async {
                if let key = key as? Key, let self = self, let cachedObject = self.cache.value(forKey: key) {
                    promise(.success(.returned(cachedObject)))
                } else {
                    promise(.success(.none))
                }
            }
        }
    }
    
    func getCachedObjects(for keys: [Codable]) -> Future<ReturnedType<[Codable]>, Never> {
        Future { [weak self] promise in
            guard let self = self else { return promise(.success(.none))}
            self.dispatchQueue.async {
                let hashKeys = keys.compactMap { $0 as? Key }
                let cachedObjects = hashKeys.compactMap { self.cache.value(forKey: $0) }
                cachedObjects.count > 0 ? promise(.success(.returned(cachedObjects))) : promise(.success(.none))
            }
        }
    }
    
    func removeStorage() {
        dispatchQueue.async { [weak self] in
            try? self?.cache.removeAllValues()
        }
    }
    
    func removeObject(for key: Codable) {
        guard let key = key as? Key else { return }
        dispatchQueue.async { [weak self] in
            try? self?.cache.removeValue(forKey: key)
        }
    }
    
}

