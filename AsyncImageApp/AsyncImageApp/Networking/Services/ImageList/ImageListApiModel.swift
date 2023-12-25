//
//  ImageListApiModel.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

public enum ImageListApiModel {
    public struct Request: Encodable {
        public init() {}
    }
    
    public struct Response: Decodable {
        public let id: Int
        public let imageUrlString: String?
        
        public enum CodingKeys: String, CodingKey {
            case id
            case imageUrlString = "imageUrl"
        }
    }
    
}
