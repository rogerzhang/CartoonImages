import UIKit
import StoreKit

// Auth State
struct AuthState {
    var isLoggedIn: Bool = false
    var token: String? = nil
    var error: String? = nil
}

// Image State
struct ImageState {
    var selectedImage: UIImage?
    var processedImage: UIImage?
    var isProcessing: Bool = false
    var error: String?
    var showError: Bool = false
    var showTips: Bool = false
    var modelTypes: [ImageModelType]?
    var currentModelType: ImageModelType?
}

struct PaymentState {
    var isProcessing: Bool = false
    var error: String?
    var selectedPlan: PaymentPlanType?
    var isSubscribed: Bool = false
    var processingStep: Int = 0
    var products: [SKProduct] = []
}

// App State
struct AppState {
    var authState: AuthState
    var imageState: ImageState
    var paymentState: PaymentState
    
    init() {
        self.authState = AuthState()
        self.imageState = ImageState()
        self.imageState.modelTypes = [
            .init(id: "1", name: "动漫风格", imageName: "1", modelId: "0", orignImage: "1-1"),
            .init(id: "2", name: "油画风格", imageName: "2", modelId: "2", orignImage: "2-1"),
            .init(id: "3", name: "水彩风格", imageName: "3", modelId: "3", orignImage: "3-1"),
            .init(id: "4", name: "素描风格", imageName: "4", modelId: "1", orignImage: "4-1"),
            .init(id: "5", name: "铅笔画", imageName: "5", modelId: "4", orignImage: "5-1"),
            .init(id: "6", name: "复古风格", imageName: "6", modelId: "5", orignImage: "6-1"),
//            .init(id: "7", name: "图片复原", imageName: "6", modelId: "0"),
        ]
        self.paymentState = PaymentState()
    }
} 
