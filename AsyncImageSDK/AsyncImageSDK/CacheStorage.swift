//
//  CacheStorage.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

final class CacheStorage<Key: Hashable, Value> where Key: Codable, Value: Codable {
        
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let keyTracker = KeyTracker()
    private let dispatchQueue = DispatchQueue(label: "QueueCacheStorage", qos: .background)
    
     init(dateProvider: @escaping () -> Date = Date.init, maximumEntryCount: Int = 100) {
        self.dateProvider = dateProvider
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
     func insert(_ value: Value, forKey key: Key, expiryInterval: Int? = nil) throws {
        let date =  dateProvider().adding(seconds: expiryInterval)
        let hasExpiration: Bool = expiryInterval == nil ? false : true
        let entry = Entry(key: key, value: value, expirationDate: date, hasExpiration: hasExpiration)
        
        guard self.entry(forKey: key) == nil else { return }
        
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
        
        if let keyString = key as? String {
            do {
                try DiskStorage.store(entry, to: .caches, as: keyString)
            } catch {
                throw CachedObjectError.objectIsNotStored
            }
        }
    }
    
    
     func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            if let keyString = key as? String {
                guard let entry = try? DiskStorage.retrieve(keyString, from: .caches, as: Entry.self) else {
                    return nil
                }
                return getValue(from: entry, with: key)
            } else {
                return nil
            }
        }
        return getValue(from: entry, with: key)
    }
    
    
    private func getValue(from entry: Entry, with key: Key) -> Value? {
        guard entry.hasExpiration else {
            return entry.value
        }
        
        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            try? removeValue(forKey: key)
            
            return nil
        }
        return entry.value
    }
    
    
     func removeValue(forKey key: Key) throws {
        wrapped.removeObject(forKey: WrappedKey(key))
        do {
            if let keyString = key as? String {
                try DiskStorage.remove(keyString, from: .caches)
            }
        } catch {
            throw CachedObjectError.objectIsNotRemoved
        }
    }
    
    
     func removeAllValues() throws {
        var keys = [WrappedKey]()
        keyTracker.keys.forEach { keys.append(WrappedKey($0)) }
        if keys.count > 0 {
            keys.forEach { wrapped.removeObject(forKey: $0) }
            do {
                try DiskStorage.clear(.caches)
            } catch {
                throw CachedObjectError.objectsAreNotDeleted
            }
        }
    }

}

// MARK: - Subscript extension

 extension CacheStorage {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using subscript,
                // then remove any value will be removed for that key:
                try? removeValue(forKey: key)
                return
            }
            try? insert(value, forKey: key)
        }
    }
}


// MARK: - Codable extensions

extension CacheStorage.Entry: Codable where Key: Codable, Value: Codable {}

extension CacheStorage: Codable where Key: Codable, Value: Codable {
     convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

     func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

// MARK: - Permanent storage
 extension CacheStorage where Key: Codable, Value: Codable {
    class DiskStorage {
        fileprivate init() { }
        
        // MARK: - Threading Considerations By Apple
        /*
         https://developer.apple.com/documentation/foundation/filemanager
         The methods of the shared FileManager object can be called from multiple threads safely.
         However, if you use a delegate to receive notifications about the status of move, copy,
         remove, and link operations, you should create a unique instance of the file manager object,
         assign your delegate to that object, and use that file manager to initiate your operations.
         */
        
        enum StorageDirectory {
            // MARK: - By Apple about documents folder
            // Only documents and other data that is user-generated,
            // or that cannot otherwise be recreated by your application,
            // should be stored in the <Application_Home>/Documents directory
            // and will be automatically backed up by iCloud.
            case documents
            
            // MARK: - By Apple about caches folder
            // Data that can be downloaded again or regenerated
            // should be stored in the <Application_Home>/Library/Caches directory.
            // Examples of files you should put in the Caches directory include
            // database cache files and downloadable content, such as that
            // used by magazine, newspaper, and map applications.
            case caches
        }
        
        // Returns URL constructed from specified directory
        static fileprivate func getURL(for directory: StorageDirectory) -> ReturnedType<URL> {
            var searchPathDirectory: FileManager.SearchPathDirectory
            
            switch directory {
            case .documents:
                searchPathDirectory = .documentDirectory
            case .caches:
                searchPathDirectory = .cachesDirectory
            }
            
            if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
                return .returned(url)
            } else {
                return .none
            }
        }
        
        // Store an encodable struct to the specified directory on disk
        static fileprivate func store(_ object: Entry, to directory: StorageDirectory, as fileName: String) throws {
            switch getURL(for: directory) {
            case .none:
                throw CachedObjectError.objectNotFound
            case .returned(let url):
                let folderUrl = url.appendingPathComponent(String(reflecting: Value.self), isDirectory: true)
                let fileUrl = folderUrl.appendingPathComponent(fileName, isDirectory: false)
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(object)
                    
                    var isDir : ObjCBool = false
                    if !FileManager.default.fileExists(atPath: folderUrl.path, isDirectory:&isDir) {
                        try FileManager.default.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    if FileManager.default.fileExists(atPath: fileUrl.path) {
                        try FileManager.default.removeItem(at: url)
                    }
                    FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
                    try data.write(to: fileUrl)
                } catch {
                    throw CachedObjectError.objectIsNotStored
                }
            }
        }
        
        // Retrieve and convert a struct from a file on disk
        static fileprivate func retrieve(_ fileName: String, from directory: StorageDirectory, as type: Entry.Type) throws -> Entry {
            switch getURL(for: directory) {
            case .none:
                throw CachedObjectError.objectNotFound
            case .returned(let url):
                let folderUrl = url.appendingPathComponent(String(reflecting: Value.self), isDirectory: true)
                let fileUrl = folderUrl.appendingPathComponent(fileName, isDirectory: false)
                
                if !FileManager.default.fileExists(atPath: fileUrl.path) {
                    throw CachedObjectError.objectNotFound
                }
                
                if let data = FileManager.default.contents(atPath: fileUrl.path) {
                    let decoder = JSONDecoder()
                    do {
                        let model = try decoder.decode(type, from: data)
                        return model
                    } catch {
                        throw CachedObjectError.objectIsNotRetreived
                    }
                } else {
                    throw CachedObjectError.objectIsNotRetreived
                }
            }
        }
            
        // Remove all files at specified directory
        static func clear(_ directory: StorageDirectory) throws {
            switch getURL(for: directory) {
            case .none:
                throw CachedObjectError.objectNotFound
            case .returned(let url):
                do {
                    let folderUrl = url.appendingPathComponent(String(reflecting: Value.self), isDirectory: true)
                    let contents = try FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: [])
                    for fileUrl in contents {
                        try FileManager.default.removeItem(at: fileUrl)
                    }
                } catch {
                    throw CachedObjectError.objectsAreNotDeleted
                }
            }
        }
        
        // Remove specified file from specified directory
        static func remove(_ fileName: String, from directory: StorageDirectory) throws {
            switch getURL(for: directory) {
            case .none:
                throw CachedObjectError.objectNotFound
            case .returned(let url):
                let folderUrl = url.appendingPathComponent(String(reflecting: Value.self), isDirectory: true)
                let fileUrl = folderUrl.appendingPathComponent(fileName, isDirectory: false)
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    do {
                        try FileManager.default.removeItem(at: fileUrl)
                    } catch {
                        throw CachedObjectError.objectIsNotRemoved
                    }
                }
            }
        }
        
        // Returns BOOL indicating whether file exists at specified directory with specified file name
        static func fileExists(_ fileName: String, in directory: StorageDirectory) -> Bool {
            switch getURL(for: directory) {
            case .none:
                return false
            case .returned(let url):
                let folderUrl = url.appendingPathComponent(String(reflecting: Value.self), isDirectory: true)
                let fileUrl = folderUrl.appendingPathComponent(fileName, isDirectory: false)
                return FileManager.default.fileExists(atPath: fileUrl.path)
            }
        }
        
    }
}

// MARK: - Private extensions

private extension CacheStorage {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}

private extension CacheStorage {
    final class Entry {
        let value: Value
        let expirationDate: Date
        // Here is needed prop - key, to track what keys among entries contain cache,
        // since cache itself doesnt reveal these keys
        let key: Key
        let hasExpiration: Bool

        init(key: Key, value: Value, expirationDate: Date, hasExpiration: Bool) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
            self.hasExpiration = hasExpiration
        }
    }
}

private extension CacheStorage {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

private extension CacheStorage {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard entry.hasExpiration else {
            return entry
        }

        guard dateProvider() < entry.expirationDate else {
            try? removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

