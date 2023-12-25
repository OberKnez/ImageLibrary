//
//  UIKitViewModel.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 24.12.23.
//

import Foundation
import Combine
import UIKit.UIImage
import AsyncImageSDK

protocol UIKitViewModel {
    func clearCache()
    func fetchImages()
    var asyncImages: AnyPublisher<[(AsyncImagerType, String)], Never> { get }
}

final class DefaultUIKitViewModel: UIKitViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var asyncImagesArray: [(AsyncImagerType, String)] = []
    
    private var asyncImagesSubject = CurrentValueSubject<[(AsyncImagerType, String)], Never>([])
    
    var asyncImages: AnyPublisher<[(AsyncImagerType, String)], Never> {
        return asyncImagesSubject
            .dropFirst()
            .eraseToAnyPublisher()
    }
    
    func clearCache() {
        AsyncImageManager.shared.downloadService.emptyCache()
    }
    
    func fetchImages() {
        AppDIContainer.shared.imageRepository.fetchImages()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("Handle Error in real app, error: \(error.debugDescription)")
                }
            } receiveValue: { [weak self] images in
                self?.getAsyncImages(images)
            }
            .store(in: &cancellables)

    }
    
    private func getAsyncImages(_ imageModels: [ImageModel]) {
        for model in imageModels {
            if let url = model.imageUrl?.absoluteString {
                let imager = AsyncImager.getAsyncImage(url: url, placeholder: UIImage(systemName: "car"))
                asyncImagesArray.append((imager, String(model.id)))
            }
        }
        asyncImagesSubject.send(asyncImagesArray)
    }
}
