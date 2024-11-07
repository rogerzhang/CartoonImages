import Foundation
import Moya
import Combine
import UIKit

struct ImageResponse: Decodable {
    let status: String
    let images: String  // base64 encoded image
}

class NetworkService {
    static let shared = NetworkService()
    private let provider = MoyaProvider<API>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])
    
    private init() {}
    
    func login(username: String, password: String) -> AnyPublisher<User, MoyaError> {
        return provider.requestPublisher(API.login(username: username, password: password))
            .filterSuccessfulStatusCodes()
            .map(User.self)
            .eraseToAnyPublisher()
    }
    
    func processImage(_ image: UIImage, modelType: String = "1") -> AnyPublisher<UIImage, ProcessImageError> {
        return provider.requestPublisher(API.processImage(image: image, modelType: modelType))
            .tryMap { response -> UIImage in
                // 解析 JSON 响应
                let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: response.data)
                
                // 检查状态
                guard imageResponse.status == "success" else {
                    throw ProcessImageError.serverError("Processing failed")
                }
                
                // 将 base64 字符串转换为图片
                guard let imageData = Data(base64Encoded: imageResponse.images),
                      let processedImage = UIImage(data: imageData) else {
                    throw ProcessImageError.invalidResponse
                }
                
                return processedImage
            }
            .mapError { error -> ProcessImageError in
                if let processError = error as? ProcessImageError {
                    return processError
                }
                return ProcessImageError.unknown(error)
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
        case .stringMapping(_):
            return "stringMapping occurred"
        }
    }
}

enum ProcessImageError: LocalizedError {
    case noFaceDetected
    case invalidResponse
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noFaceDetected:
            return "No face was detected in the image. Please select a photo with a clear face."
        case .invalidResponse:
            return "Unable to process the server response."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var userMessage: String {
        switch self {
        case .noFaceDetected:
            return "Please select a photo with a clear face visible."
        case .invalidResponse:
            return "Unable to process the image. Please try again."
        case .serverError:
            return "Server error. Please try again later."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
} 
