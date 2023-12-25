//
//  ImageListRepository.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine
import AsyncImageSDK

public struct ImageListRepository: ImageListRepositoryProtocol {
    private let service: ImageListServiceProtocol
    
    public init(service: ImageListServiceProtocol) {
        self.service = service
    }
    
    public func fetchImages() -> AnyPublisher<[ImageModel], NetworkError> {
        service
            .fetchImages(.init())
            .map { response in
                response.map {
                    ImageModel(id: $0.id, imageUrlString: $0.imageUrlString, date: Date.now)
                }
            }
            .eraseToAnyPublisher()
    }
}
    
