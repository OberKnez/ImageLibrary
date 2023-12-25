//
//  ImageListService.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine
import AsyncImageSDK

public struct ImageListService: ImageListServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func fetchImages(
        _ request: ImageListApiModel.Request
    ) -> AnyPublisher<[ImageListApiModel.Response], NetworkError> {
        networkService.execute(
            request: ImageListEndpoint.fetchImages(request)
        )
    }
    
}

