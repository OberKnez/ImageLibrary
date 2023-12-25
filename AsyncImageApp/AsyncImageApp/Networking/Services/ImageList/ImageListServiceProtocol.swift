//
//  ImageListServiceProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine
import AsyncImageSDK

public protocol ImageListServiceProtocol {
    
    func fetchImages(
        _ request: ImageListApiModel.Request
    ) -> AnyPublisher<[ImageListApiModel.Response], NetworkError>
    
}
