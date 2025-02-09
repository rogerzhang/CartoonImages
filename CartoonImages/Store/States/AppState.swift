import UIKit
import StoreKit

// Auth State
struct AuthState {
    var isLoggedIn: Bool = false
    var token: String? = nil
    var error: String? = nil
    var config: [ImageProcessingEffect]?
    var isLoadingConfig: Bool = false
}

// Image State
struct ImageState {
    var selectedImage: UIImage?
    var processedImage: UIImage?
    var isProcessing: Bool = false
    var error: String?
    var showError: Bool = false
    var showTips: Bool = false
    var modelTypes: [ImageProcessingEffect]?
    var currentModelType: ImageProcessingEffect?
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
        ]
        self.paymentState = PaymentState()
    }
} 
