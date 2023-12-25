//
//  AsyncImagerView.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 24.12.23.
//

import UIKit
import Combine
import SwiftUI

public protocol AsyncImagerType {
    var urlString: String { get set }
    var placeholder: UIImage? { get set }
    var imageView: UIImageView? { get set }
//    associatedtype T
//    var view: T { get set }
}

final class AsyncImagerView: AsyncImagerType {
//    var view: UIImageView = {
//        let view = UIImageView(frame: .zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    var urlString: String
    var placeholder: UIImage?
    
    private var cancellables = Set<AnyCancellable>()
    
    lazy var imageView: UIImageView? = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var asyncView: AnyView = AnyView(Text(""))
        
    init(url: String, _ placeholder: UIImage? = nil) {
        self.urlString = url
        self.placeholder = placeholder
        getImage()
    }
    
    private func getImage() {
        
        DispatchQueue.main.async { [weak self] in
            guard let imgView = self?.imageView, let self = self else { return }
            if imgView.image == nil {
                imgView.image = self.placeholder
                imgView.contentMode = .scaleAspectFit
            }
        }
        
        let imageDescriptor = AsyncImageModel(url: URL(string: urlString), placeholder: placeholder)
        
        AsyncImageManager.shared.downloadService.getImage(descriptor: imageDescriptor)
            .receive(on: DispatchQueue.global())
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): debugPrint("Error occured: ", error.localizedDescription)
                }
            } receiveValue: { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView?.image = image
                    self?.imageView?.contentMode = .scaleAspectFit
                }
            }
            .store(in: &cancellables)
    }
}


public struct AsyncImagerSwiftUIView: View, AsyncImagerType {
    
    public var urlString: String
    public var placeholder: UIImage?
        
    public var body: some SwiftUI.View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .scaledToFit()
            
        } placeholder: {
            Image(uiImage: placeholder ?? UIImage(systemName: "car")!)
                .resizable()
                .scaledToFit()
        }

    }
    
    public var imageView: UIImageView? 
    
}


public struct AsyncImager {
    public static func getAsyncImage(url: String, placeholder: UIImage? = nil) -> AsyncImagerType {
        switch AsyncImageManager.config.interface {
        case .SwiftUI: return AsyncImagerSwiftUIView(urlString: url, placeholder: placeholder)
        case .UIKit: return AsyncImagerView(url: url, placeholder)
        }
    }
}
