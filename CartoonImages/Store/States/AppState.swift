import UIKit

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

// Payment State
struct PaymentState {
    var isProcessing: Bool = false
    var error: String? = nil
    var showError: Bool = false
    var lastTransactionId: String? = nil
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
            .init(id: "1", name: "动漫风格", imageName: "1"),
            .init(id: "2", name: "素描风格", imageName: "2"),
            .init(id: "3", name: "油画风格", imageName: "3"),
            .init(id: "4", name: "水彩风格", imageName: "4"),
            .init(id: "5", name: "铅笔画", imageName: "5"),
            .init(id: "6", name: "复古风格", imageName: "6"),
        ]
        self.paymentState = PaymentState()
    }
} 
