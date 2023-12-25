//
//  Requestable.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public protocol Requestable {
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var path: String { get }
    var body: Encodable? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Requestable {
    
    public var headers: HTTPHeaders? {
        nil
    }
    
    public func createURLRequest(with configuration: NetworkConfigurationProtocol) -> URLRequest? {
        guard var url = URL(string: configuration.environment.host) else {
            return nil
        }
        url.appendPathComponent(path)

        guard var urlComponents = URLComponents(string: url.absoluteString) else {
            return nil
        }

        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body?.encode()
        urlRequest.allHTTPHeaderFields = configuration.headers
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }
}

// MARK: - Encodable

private extension Encodable {
    
    func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
