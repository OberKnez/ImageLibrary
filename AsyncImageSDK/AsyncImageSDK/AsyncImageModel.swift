//
//  AsyncImageModel.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import UIKit

struct AsyncImageModel: ImageDescriptor {
    var url: URL?
    let placeholder: UIImage?
    
    init(url: URL?, placeholder: UIImage?) {
        self.url = url
        self.placeholder = placeholder
    }
}

extension AsyncImageModel: Equatable {
    static func == (lhs: AsyncImageModel, rhs: AsyncImageModel) -> Bool {
        return lhs.url?.absoluteString == rhs.url?.absoluteString
    }
}
