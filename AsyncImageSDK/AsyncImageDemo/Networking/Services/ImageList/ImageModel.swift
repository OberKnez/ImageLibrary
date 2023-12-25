//
//  ImageModel.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import UIKit.UIImage

public struct ImageModel {
    public let id: Int
    public let imageUrlString: String?
    
    public var imageUrl: URL? {
        guard let imageUrlString = self.imageUrlString else { return nil }
        return URL(string: imageUrlString)
    }
    
    public let date: Date?
}
