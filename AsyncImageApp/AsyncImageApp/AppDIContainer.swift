//
//  AppDIContainer.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import AsyncImageSDK

public final class AppDIContainer {
    
    public static let shared = AppDIContainer()
    
    private init() {
        AsyncImageManager.setup(.init(interface: .UIKit))
    }
    
    // MARK: - Network Service
    lazy var networkService: NetworkServiceProtocol = {
        lazy var environmentService: EnvironmentServiceProtocol = EnvironmentService()
        
        let networkConfiguration: NetworkConfigurationProtocol = NetworkConfiguration(
            environment: environmentService.environment
        )
        return NetworkService(
            session: URLSession.shared,
            networkConfiguration: networkConfiguration
        )
    }()
    
    lazy var imageRepository: ImageListRepositoryProtocol = {
        let imageListService: ImageListServiceProtocol = ImageListService(networkService: networkService)
        
        return ImageListRepository(service: imageListService)
    }()
    
    
}
