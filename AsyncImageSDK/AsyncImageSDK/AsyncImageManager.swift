//
//  AsyncImageManager.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation

public enum InterfaceType {
    case SwiftUI
    case UIKit
}

public final class AsyncImageManager {
    
    public struct Config {
        public init(interface: InterfaceType) {
            self.interface = interface
        }
        var interface: InterfaceType
    }
    static private(set) var config: Config!
    
    public class func setup(_ config: Config) {
        AsyncImageManager.config = config
    }
    
    public class func changeInterface(_ type: InterfaceType) {
        AsyncImageManager.config.interface = type
    }
    
    public static let shared = AsyncImageManager()
    
    private init() {
        guard let _ = AsyncImageManager.config else {
            fatalError("Error - you must call setup before accessing AsyncImageManager.shared")
        }
    }
    
    public lazy var downloadService: DownloadServiceProtocol = {
        DownloadService()
    }()
    
}
