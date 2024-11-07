import Foundation
import Moya
import UIKit

enum API {
    case login(username: String, password: String)
    case processImage(image: UIImage, modelType: String)
    case fetchProducts
    case purchase(productId: String)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "http://192.168.1.20:8080")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
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
        case .login, .processImage, .purchase:
            return .post
        case .fetchProducts:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .login(username, password):
            return .requestParameters(
                parameters: ["username": username, "password": password],
                encoding: JSONEncoding.default
            )
        case let .processImage(image, modelType):
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                return .requestPlain
            }
            
            let formData: [MultipartFormData] = [
                MultipartFormData(
                    provider: .data(imageData),
                    name: "file",
                    fileName: "image.jpg",
                    mimeType: "image/jpeg"
                ),
                MultipartFormData(
                    provider: .data(modelType.data(using: .utf8)!),
                    name: "modelType"
                )
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
        var headers = [
            "Accept": "application/json"
        ]
        if let token = mainStore.state.authState.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
} 
