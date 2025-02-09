import Foundation
import Moya
import UIKit

enum API {
    case getHomeConfig
    case processImage(imageData: Data, modelType: String)
    case clearerImage(imageData: Data, modelType: String)
    case fetchProducts
    case purchase(productId: String)
}

extension API: TargetType {
    var baseURL: URL {
        // Check the user's region
        let regionCode = Locale.current.region?.identifier ?? "US" // Default to US if region code is not available
        if regionCode == "CN" {
            return URL(string: "https://main.holymason.cn")! // China mainland
        } else {
            return URL(string: "https://hk.holymason.cn")! // Other regions
        }
    }
    
    var path: String {
        switch self {
        case .getHomeConfig:
            return "/pageConfig/api/home"
        case .processImage:
            return "/image/process/"
        case .clearerImage:
            return "/clearer/process/"
        case .fetchProducts:
            return "/products"
        case .purchase:
            return "/purchase"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .processImage, .clearerImage:
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
        case .fetchProducts, .getHomeConfig:
            return .requestPlain
        case let .purchase(productId):
            return .requestParameters(
                parameters: ["productId": productId],
                encoding: JSONEncoding.default
            )
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
} 
