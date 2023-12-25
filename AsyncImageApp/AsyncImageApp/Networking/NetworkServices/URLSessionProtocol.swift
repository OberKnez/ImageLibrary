//
//  URLSessionProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public protocol URLSessionProtocol {

    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

// MARK: - URLSession

extension URLSession: URLSessionProtocol { }
