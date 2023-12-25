//
//  DownloadService.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Combine
import UIKit.UIImage

final class DownloadService: DownloadServiceProtocol {
    
    lazy var cacheService = IoCManager.shared.resolve(key: String.self, value: ImageWrapper.self)
    
    func removeCachedData(descripton: ImageDescriptor) {
        cacheService.removeObject(for: descripton.url?.absoluteString)
    }
    
    func emptyCache() {
        cacheService.removeStorage()
    }
    
    
    func getImage(descriptor: ImageDescriptor) -> AnyPublisher<UIImage?, Error> {
        return Just(descriptor)
            .eraseToAnyPublisher()
            .map { [weak self] returnedType -> Future<ReturnedType<Codable>, Never> in
                guard let self = self else {
                    return Future { promise in promise(.success(.none)) }
                }
                return self.cacheService.getCachedObject(for: descriptor.url?.absoluteString)
            }
            .switchToLatest()
            .map { [weak self] returnType -> AnyPublisher<UIImage?, Error> in
                guard let self = self else {
                    return Just(nil).tryMap { $0 }.eraseToAnyPublisher()
                }
                switch returnType {
                case .none:
                    return self.fetchImage(descriptor: descriptor)
                    
                case .returned(let imageWrapper):
                    guard let imageWrapper = imageWrapper as? ImageWrapper else {
                        return Just(nil).tryMap { $0 }.eraseToAnyPublisher()
                    }
                    return Just(imageWrapper.image).tryMap { $0 }.eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    
    private func fetchImage(descriptor: ImageDescriptor) -> AnyPublisher<UIImage?, Error> {
        guard let url = descriptor.url else {
            // return Just(descriptor.placeholder).tryMap { $0 }.eraseToAnyPublisher()
            return Just(nil).tryMap { $0 }.eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError { $0 }
            .handleEvents(receiveOutput: { [weak self] in
                guard let image: UIImage = ($0 ?? descriptor.placeholder) else {
                    return
                }
                self?.cacheService.store(ImageWrapper(image: image), for: descriptor.url?.absoluteString, expirationInSeconds: 14400)
            })
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
        
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
                  return nil
        }
        
        return image
    }
    
}
