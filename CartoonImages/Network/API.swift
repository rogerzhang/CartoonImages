import Foundation
import Moya
import UIKit

enum API {
    case login(username: String, password: String)
    case processImage(image: UIImage)
    case fetchProducts
    case purchase(productId: String)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "https://your-api-base-url.com")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .processImage:
            return "/image/process"
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
        case let .processImage(image):
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                return .requestPlain
            }
            let formData = MultipartFormData(provider: .data(imageData), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            return .uploadMultipart([formData])
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
        var headers = ["Content-Type": "application/json"]
        if let token = mainStore.state.authState.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
} 