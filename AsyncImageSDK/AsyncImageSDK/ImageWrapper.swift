//
//  ImageWrapper.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import UIKit

struct ImageWrapper: Codable {
    public let image: UIImage
    public let width: Int?
    public let height: Int?
    
    public enum CodingKeys: String, CodingKey {
        case image, width, height
    }
    
    public init(image: UIImage, width: Int? = nil, height: Int? = nil) {
        self.image = image
        self.width = width
        self.height = height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = UIImage(data: data) else {
            throw CachedObjectError.canNotCreateObjectFromData
        }
        self.width = try container.decodeIfPresent(Int.self, forKey: .width)
        self.height = try container.decodeIfPresent(Int.self, forKey: .height)
        self.image = image
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = image.pngData() else {
            throw CachedObjectError.dataCouldNotBeCreated
        }
        
        try container.encode(data, forKey: CodingKeys.image)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
    }
}
