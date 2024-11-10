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
        self.paymentState = PaymentState()
    }
} 
