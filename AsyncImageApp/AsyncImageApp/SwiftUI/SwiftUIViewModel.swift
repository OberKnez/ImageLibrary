//
//  SwiftUIViewModel.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 25.12.23.
//

import SwiftUI
import Combine
import AsyncImageSDK

struct AsyncImageWrapper: Hashable {
    static func == (lhs: AsyncImageWrapper, rhs: AsyncImageWrapper) -> Bool {
        lhs.id == rhs.id
    }
    
    let asyncImage: (AsyncImagerType, String)
    
    var id: String = UUID().uuidString
    
    func hash(into hasher: inout Hasher) {
       hasher.combine(id)
     }
}

class SwiftUIViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var asyncImagesArray: [AsyncImageWrapper] = []
    
    @Published var asyncImages: [AsyncImageWrapper] = []
    
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
                asyncImagesArray.append(AsyncImageWrapper.init(asyncImage: (imager, String(model.id))))
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.asyncImages = self.asyncImagesArray
        }
        
    }
}
