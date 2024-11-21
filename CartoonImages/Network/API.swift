import Foundation
import Moya
import UIKit

enum API {
    case processImage(image: UIImage, modelType: String)
    case fetchProducts
    case purchase(productId: String)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "http://121.41.44.51:8080/")!
    }
    
    var path: String {
        switch self {
        case .processImage:
            return "/process_image/"
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
        case let .processImage(image, modelType):
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                return .requestPlain
            }
            
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
