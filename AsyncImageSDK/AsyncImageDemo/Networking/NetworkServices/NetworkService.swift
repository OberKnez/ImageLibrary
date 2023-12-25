//
//  NetworkService.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 23.12.23.
//

import Foundation
import Combine
import AsyncImageSDK

public final class NetworkService: NetworkServiceProtocol {
    private let session: URLSessionProtocol
    private let networkConfiguration: NetworkConfigurationProtocol
    private let jsonDecoder: JSONDecoder
    
    public init(
        session: URLSessionProtocol,
        networkConfiguration: NetworkConfigurationProtocol,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.networkConfiguration = networkConfiguration
        self.jsonDecoder = jsonDecoder
    }
    
    public func execute<Response>(request: Requestable) -> AnyPublisher<Response, NetworkError> where Response : Decodable {
        self.executeDataRequest(request)
            .decode(type: Response.self, decoder: jsonDecoder)
            .mapError { error in
                debugPrint("❌*** Network error detail: \(error)")
                guard let error = error as? NetworkError else {
                    return error.resolve
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    
    private func executeDataRequest(_ request: Requestable) -> AnyPublisher<Data, Error> {
        let urlRequest = request.createURLRequest(with: networkConfiguration)

        guard let urlRequest = urlRequest else {
            return Fail(error: NetworkError.invalidRequest)
                .eraseToAnyPublisher()
        }
        debugPrint("*** Network request to url: \(urlRequest.url?.absoluteString ?? "")")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                switch response.statusCode {
                case 200..<400:
                    // Added to pass decoding error when no response exists
                    guard !data.isEmpty else {
                        debugPrint("*** Network data is empty. Returning empty response on client side for decoding")
                        let emptyResponseData = try? JSONEncoder().encode(EmptyResponse())
                        return emptyResponseData ?? data
                    }
                    return data
                default:
                    debugPrint("*** Network error statusCode: \(response.statusCode) for request: \(urlRequest.url?.absoluteString ?? "")")
                    throw NetworkError.invalidResponse
                }
            }
            
            .eraseToAnyPublisher()
    }
}


extension NetworkService {
    fileprivate struct EmptyResponse: Codable { }
}

fileprivate extension Error {
    
    var resolve: NetworkError {
        let code = URLError.Code(rawValue: (self as NSError).code)
        switch code {
        case .notConnectedToInternet,
             .dataNotAllowed,
             .networkConnectionLost,
             .internationalRoamingOff:
            return .networkConnection
        case .cancelled:
            return .cancelled
        case .timedOut:
            return .timeOut
        default:
            return .unknown(self)
        }
    }
}
