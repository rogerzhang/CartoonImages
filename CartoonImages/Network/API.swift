import Foundation
import Moya
import UIKit

enum API {
    case processImage(imageData: Data, modelType: String)
    case fetchProducts
    case purchase(productId: String)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "https://holymason.cn")!
//        return URL(string: "https://test.holymason.cn")!
    }
    
    var path: String {
        switch self {
        case .processImage:
            return "/image/process/"
        case .fetchProducts:
            return "/products"
        case .purchase:
            return "/purchase"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .processImage:
            return .post
        case .fetchProducts, .purchase:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .processImage(imageData, modelType):
//            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//                return .requestPlain
//            }
            
            let formData = [
                MultipartFormData(provider: .data(imageData),
                                name: "file",
                                fileName: "image.jpg",
                                mimeType: "image/jpeg"),
                MultipartFormData(provider: .data(modelType.data(using: .utf8)!),
                                name: "modelType")
            ]
            
            return .uploadMultipart(formData)
        case .fetchProducts:
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
