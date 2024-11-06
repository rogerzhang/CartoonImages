import Foundation
import ReSwift
import UIKit
import StoreKit

struct AppState: StateType {
    var authState: AuthState
    var imageState: ImageState
    var subscriptionState: SubscriptionState
    
    static func initialState() -> AppState {
        return AppState(
            authState: AuthState(),
            imageState: ImageState(),
            subscriptionState: SubscriptionState()
        )
    }
}

struct AuthState {
    var isLoggedIn: Bool = false
    var currentUser: User? = nil
    var token: String? = nil
    var error: Error? = nil
}

struct ImageState {
    var selectedImage: UIImage? = nil
    var processedImage: UIImage? = nil
    var isProcessing: Bool = false
    var error: Error? = nil
}

struct SubscriptionState {
    var products: [SKProduct] = []
    var isPurchasing: Bool = false
    var error: Error? = nil
} 
