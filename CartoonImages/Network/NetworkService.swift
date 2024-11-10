import Foundation
import Moya
import Combine
import UIKit

// 错误类型定义
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
            return message
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    // 添加 userMessage 属性
    var userMessage: String {
        return errorDescription ?? "An unknown error occurred"
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let provider = MoyaProvider<API>()
    var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func processImage(_ image: UIImage, modelType: String = "1") -> AnyPublisher<UIImage, ProcessImageError> {
        return provider.requestPublisher(.processImage(image: image, modelType: modelType))
            .tryMap { response -> UIImage in
                let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: response.data)
                
                guard imageResponse.status == "success",
                      let imageData = Data(base64Encoded: imageResponse.images),
                      let processedImage = UIImage(data: imageData) else {
                    throw ProcessImageError.invalidResponse
                }
                
                return processedImage
            }
            .mapError { error -> ProcessImageError in
                if let processError = error as? ProcessImageError {
                    return processError
                }
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        if response.statusCode == 400 {
                            if let json = try? JSONSerialization.jsonObject(with: response.data) as? [String: String],
                               let errorMessage = json["error"] {
                                return .serverError(errorMessage)
                            }
                        }
                    default:
                        break
                    }
                }
                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }
}

// 响应模型
struct ImageResponse: Decodable {
    let status: String
    let images: String
} 
