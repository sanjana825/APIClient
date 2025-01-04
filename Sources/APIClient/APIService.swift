//
//  APIService.swift
//

import Foundation
import Combine

class APIService{
    
    public init() { }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    func sendRequests<T: Decodable>(url: String, method: HTTPMethod, decodingType: T.Type) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: url) else {
                return Fail(error: NetworkError.invalidURL)
                    .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
    
            return URLSession.shared.dataTaskPublisher(for: request)
                .mapError { _ in NetworkError.requestFailed }
                .map(\.data)
                .decode(type: decodingType, decoder: JSONDecoder())
                .mapError { _ in NetworkError.decodingFailed }
                .eraseToAnyPublisher()
    }
}

public enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case timeout
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

extension NetworkError: LocalizedError {
    public var errorDescription: String?{
        switch self{
        case .invalidURL: return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .requestFailed: return NSLocalizedString("Request Failed", comment: "Request Failed")
        case .decodingFailed: return NSLocalizedString("Error while decoding data", comment: "Decoding Error")
        case .timeout: return NSLocalizedString("Request timed out", comment: "Timeout")
        }
    }
}


