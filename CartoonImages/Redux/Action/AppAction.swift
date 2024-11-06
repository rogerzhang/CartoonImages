import Foundation
import UIKit
import StoreKit
import ReSwift

enum AppAction: Action {
    case auth(AuthAction)
    case image(ImageAction)
    case subscription(SubscriptionAction)
}

enum AuthAction: Action {
    case login(username: String, password: String)
    case loginSuccess(User, String)
    case loginFailure(Error)
    case logout
}

enum ImageAction: Action {
    case selectImage(UIImage)
    case startProcessing
    case processSuccess(UIImage)
    case processFailure(Error)
    case saveToLibrary
}

enum SubscriptionAction: Action {
    case fetchProducts
    case purchaseProduct(SKProduct)
    case purchaseSuccess
    case purchaseFailure(Error)
} 
