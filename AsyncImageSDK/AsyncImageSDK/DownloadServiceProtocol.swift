//
//  DownloadServiceProtocol.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import UIKit
import Combine

public protocol ImageDescriptor {
    var url: URL? { get }
    var placeholder: UIImage? { get }
}

public protocol DownloadServiceProtocol {
    func removeCachedData(descripton: ImageDescriptor)
    func emptyCache()
    func getImage(descriptor: ImageDescriptor) -> AnyPublisher<UIImage?, Error>
}
