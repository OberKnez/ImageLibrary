//
//  NetworkServiceProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine
import AsyncImageSDK

public protocol NetworkServiceProtocol {
    
    func execute<Response>(request: Requestable) -> AnyPublisher<Response, NetworkError> where Response : Decodable
    
}
