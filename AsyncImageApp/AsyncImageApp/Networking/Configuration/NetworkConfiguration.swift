//
//  NetworkConfiguration.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import UIKit

public struct NetworkConfiguration: NetworkConfigurationProtocol {
    
    // MARK: - Public Variables
    public let environment: EnvironmentProtocol
    
    public var headers: [String: String] {
       defaultHeaders
    }
    
    // MARK: - Private Variables
    private let defaultHeaders: HTTPHeaders
    
    // MARK: - Init
    public init(environment: EnvironmentProtocol) {
        self.environment = environment
        let appVersion = (Bundle.main.infoDictionary?[BundleInfoKey.version] as? String) ?? "1.0.0"
        let appBuild = (Bundle.main.infoDictionary?[BundleInfoKey.bundle] as? String) ?? "0"
        let deviceModel = [
            "Apple",
            UIDevice.current.systemName, // iOS/iPadOS
            UIDevice.current.model,
            UIDevice.current.systemVersion
        ].joined(separator: "|")
        self.defaultHeaders = [
            HeaderKey.contentType: "application/json",
            HeaderKey.accept: "application/json",
            HeaderKey.appVersion: appVersion,
            HeaderKey.appBuild: appBuild,
            HeaderKey.deviceModel: deviceModel
        ]
    }
}


extension NetworkConfiguration {
    enum BundleInfoKey {
        static let version = "CFBundleShortVersionString"
        static let bundle = kCFBundleVersionKey as String
    }
    
    enum HeaderKey {
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let deviceModel = "deviceModel"
        static let appVersion = "appVersion"
        static let appBuild = "appBuild"
        static let userAuthorization = "User-Authorization"
    }
}
