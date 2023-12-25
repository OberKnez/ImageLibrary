//
//  CacheStorageServiceProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine

protocol CacheStorageServiceType {
    func store(_ object: Codable, for key: Codable, expirationInSeconds: Int?)
    func getCachedObject(for key: Codable) -> Future<ReturnedType<Codable>, Never>
    func getCachedObjects(for keys: [Codable]) -> Future<ReturnedType<[Codable]>, Never>
    func removeStorage()
    func removeObject(for key: Codable)
}


enum ReturnedType<T> {
   case none
   case returned(T)
}

extension Date {
   func adding(seconds: Int?) -> Date {
       guard let seconds = seconds else { return self }
       return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
   }
}
