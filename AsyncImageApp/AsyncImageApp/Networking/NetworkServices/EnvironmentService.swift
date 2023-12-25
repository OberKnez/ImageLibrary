//
//  EnvironmentService.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public final class EnvironmentService: EnvironmentServiceProtocol {

    public private(set) var environment: EnvironmentConfiguration.Environment
    
    public init() {
        #if DEBUG
        environment = .development
        #else
        environment = .production
        #endif
    }

    public func changeEnvironment(to environment: EnvironmentConfiguration.Environment) {
        self.environment = environment
    }
}
