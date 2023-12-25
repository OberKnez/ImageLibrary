//
//  EnvironmentConfiguration.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public enum EnvironmentConfiguration {
    public enum Environment: String {
        case development
        case production
    }
}

extension EnvironmentConfiguration.Environment: EnvironmentProtocol {
    
    public var host: String {
        switch self {
        case .development:
            return "https://zipoapps-storage-test.nyc3.digitaloceanspaces.com"
        case .production:
            return "https://zipoapps-storage-test.nyc3.digitaloceanspaces.com"
        }
    }
}

