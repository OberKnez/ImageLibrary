//
//  NetworkConfigurationProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public protocol NetworkConfigurationProtocol {
    var environment: EnvironmentProtocol { get }
    var headers: [String: String] { get }
}
