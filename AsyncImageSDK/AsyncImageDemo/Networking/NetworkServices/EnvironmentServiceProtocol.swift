//
//  EnvironmentServiceProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public protocol EnvironmentServiceProtocol {
    var environment: EnvironmentConfiguration.Environment { get }

    func changeEnvironment(to environment: EnvironmentConfiguration.Environment)
}
