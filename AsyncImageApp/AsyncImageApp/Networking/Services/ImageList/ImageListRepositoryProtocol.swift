//
//  ImageListRepositoryProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine
import AsyncImageSDK

public protocol ImageListRepositoryProtocol {
    func fetchImages() -> AnyPublisher<[ImageModel], NetworkError>
}
