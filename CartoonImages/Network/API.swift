import Foundation
import Moya
import UIKit

enum API {
    case getHomeConfig
    case processImage(imageData: Data, modelType: String)
    case clearerImage(imageData: Data, modelType: String)
    case smartProcessImage(imageData: Data, model: ImageProcessingEffect)
    case fetchProducts
    case purchase(productId: String)
    case fetchAnnoucement(version: Int)
    case registerDeviceToken(deviceToken: String)
}

extension API {
    static var hostAddress: String {
        let regionCode = Locale.current.region?.identifier ?? "US" // Default to US if region code is not available
#if DEBUG
        return "https://test.holymason.cn"
#else
        if regionCode == "CN" {
            return "https://main.holymason.cn" // China mainland
        } else {
            return "https://hk.holymason.cn" // Other regions
        }
#endif
    }
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: API.hostAddress)!
    }
    
    var path: String {
        switch self {
        case .getHomeConfig:
            return "/pageConfig/api/home"
        case .smartProcessImage(_, let model):
            return model.api_url
        case .processImage:
            return "/image/process/"
        case .clearerImage:
            return "/clearer/process/"
        case .fetchProducts:
            return "/products"
        case .purchase:
            return "/purchase"
        case .fetchAnnoucement:
            return "/pushAnnouncement/getAnnouncements"
        case .registerDeviceToken:
            return "/pushAnnouncement/registerToken"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .processImage, .clearerImage, .smartProcessImage, .fetchAnnoucement, .registerDeviceToken:
            return .post
        case .fetchProducts, .purchase, .getHomeConfig:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .processImage(imageData, modelType), let .clearerImage(imageData, modelType):
            let formData = [
                MultipartFormData(provider: .data(imageData),
                                name: "file",
                                fileName: "image.jpg",
                                mimeType: "image/jpeg"),
                MultipartFormData(provider: .data(modelType.data(using: .utf8)!),
                                name: "modelType")
            ]
            
            return .uploadMultipart(formData)
        case let .smartProcessImage(imageData, model):
            let formData = [
                MultipartFormData(provider: .data(imageData),
                                name: "file",
                                fileName: "image.jpg",
                                mimeType: "image/jpeg"),
                MultipartFormData(provider: .data(model.model_type.data(using: .utf8)!),
                                name: "modelType"),
                MultipartFormData(provider: .data("\(model.region)".data(using: .utf8)!),
                                name: "region")
            ]
            
            return .uploadMultipart(formData)
        case .fetchProducts, .getHomeConfig:
            return .requestPlain
        case let .purchase(productId):
            return .requestParameters(
                parameters: ["productId": productId],
                encoding: JSONEncoding.default
            )
        case let .fetchAnnoucement(version):
            return .requestParameters(
                parameters: ["version": version],
                encoding: URLEncoding.default
            )
        case let .registerDeviceToken(deviceToken):
            return .requestParameters(
                parameters: ["token": deviceToken],
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
} 
