import Foundation
import Moya
import Combine
import UIKit

enum NetworkError: LocalizedError {
    case invalidResponse
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Unable to process the server response."
        case .serverError(let message):
            return message
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

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
    
    func getHomeConfig() -> AnyPublisher<[ImageProcessingEffect], NetworkError> {
        let target = API.getHomeConfig
        
        return provider.requestPublisher(target)
            .tryMap { response in
                let imageResponse = try JSONDecoder().decode(Response.self, from: response.data)
                
                guard imageResponse.status == "success" else {
                    throw NetworkError.invalidResponse
                }
                return imageResponse.data
            }
            .mapError { error in
                if let processError = error as? NetworkError {
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
    
    func processImage(_ imageData: Data, model: ImageProcessingEffect) -> AnyPublisher<UIImage, ProcessImageError> {
        let size = imageData.count
        print("size === \(size / 1000)KB")
        let target = API.smartProcessImage(imageData: imageData, model: model)
        
        return provider.requestPublisher(target)
            .tryMap { response -> UIImage in
                Logger.shared.log("statusCode is: \(response.statusCode)")
                let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: response.data)
                
                guard imageResponse.status == "success",
                      let imageData = Data(base64Encoded: imageResponse.images),
                      let processedImage = UIImage(data: imageData) else {
                    throw ProcessImageError.invalidResponse
                }
                print("====[CM]END: \(Date.now)")
                if mainStore.state.paymentState.isSubscribed {
                    return processedImage
                } else {
                    return WatermarkManager.addWatermark(to: processedImage)

                }
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
    
    func processImage1(_ imageData: Data, modelType: String = "1") -> AnyPublisher<UIImage, ProcessImageError> {
        let size = imageData.count
        print("size === \(size / 1000)KB")
        return provider.requestPublisher(.processImage(imageData: imageData, modelType: modelType))
            .tryMap { response -> UIImage in
                let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: response.data)
                
                guard imageResponse.status == "success",
                      let imageData = Data(base64Encoded: imageResponse.images),
                      let processedImage = UIImage(data: imageData) else {
                    throw ProcessImageError.invalidResponse
                }
                print("====[CM]END: \(Date.now)")
                if mainStore.state.paymentState.isSubscribed {
                    return processedImage
                } else {
                    return WatermarkManager.addWatermark(to: processedImage)

                }
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

struct Response: Decodable {
    let status: String
    let data: [ImageProcessingEffect]
}

struct ImageProcessingEffect: Codable, Identifiable {
    let region: Int
    let image_url: String
    let title: String
    let api_url: String
    let model_type: String
    let sort_order: Int
    let orign_img: String
    let remark: String
    let titleZh: String
    let remarkZh: String
    let id: Int
    
    var imageUrl: String {
        API.hostAddress + image_url
    }
    
    var origImgUrl: String {
        API.hostAddress + orign_img
    }
}
