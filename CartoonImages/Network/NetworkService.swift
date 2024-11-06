import Foundation
import Moya
import Combine
import UIKit

class NetworkService {
    static let shared = NetworkService()
    private let provider = MoyaProvider<API>()
    
    private init() {}
    
    func login(username: String, password: String) -> AnyPublisher<User, MoyaError> {
        return provider.requestPublisher(API.login(username: username, password: password))
            .filterSuccessfulStatusCodes()
            .map(User.self)
            .eraseToAnyPublisher()
    }
    
    func processImage(_ image: UIImage) -> AnyPublisher<UIImage, MoyaError> {
        return provider.requestPublisher(API.processImage(image: image))
            .filterSuccessfulStatusCodes()
            .tryMap { response -> UIImage in
                if let image = UIImage(data: response.data) {
                    return image
                }
                throw MoyaError.jsonMapping(response)
            }
            .mapError { error -> MoyaError in
                if let moyaError = error as? MoyaError {
                    return moyaError
                }
                return MoyaError.underlying(error, nil)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchProducts() -> AnyPublisher<[Product], MoyaError> {
        return provider.requestPublisher(API.fetchProducts)
            .filterSuccessfulStatusCodes()
            .map([Product].self)
            .eraseToAnyPublisher()
    }
    
    func purchase(productId: String) -> AnyPublisher<Void, MoyaError> {
        return provider.requestPublisher(API.purchase(productId: productId))
            .filterSuccessfulStatusCodes()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension MoyaError {
    var displayDescription: String {
        switch self {
        case .imageMapping:
            return "Failed to convert data to image"
        case .jsonMapping:
            return "Failed to parse server response"
        case .statusCode(let response):
            return "Server error: \(response.statusCode)"
        case .underlying(let error, _):
            return error.localizedDescription
        case .requestMapping:
            return "Failed to create request"
        case .parameterEncoding(let error):
            return "Parameter encoding failed: \(error.localizedDescription)"
        case .objectMapping(let error, _):
            return "Object mapping failed: \(error.localizedDescription)"
        case .encodableMapping(let error):
            return "Encodable mapping failed: \(error.localizedDescription)"
        @unknown default:
            return "Unknown error occurred"
        }
    }
} 