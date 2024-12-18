import ReSwift
import StoreKit

// 主状态
struct AppState {
    var payment = PaymentState()
    var auth = AuthState()
    var image = ImageState()
}

// 支付状态
struct PaymentState {
    var isProcessing: Bool = false
    var error: String?
    var selectedPlan: PaymentPlanType?
    var isSubscribed: Bool = false
    var processingStep: Int = 0
    var products: [SKProduct] = []
}

// 认证状态
struct AuthState {
    var isLoggedIn: Bool = false
    var user: User?
    var error: String?
}

// 图片处理状态
struct ImageState {
    var selectedImage: UIImage?
    var processedImage: UIImage?
    var selectedModelType: ImageModelType?
    var isProcessing: Bool = false
    var error: String?
}

// 支付动作
enum PaymentAction: Action {
    case startPayment(PaymentPlanType)
    case paymentSuccess
    case paymentFailure(Error)
    case updateSubscriptionStatus(Bool)
    case selectPlan(PaymentPlanType?)
    case updateProcessingStep(Int)
    case updateProducts([SKProduct])
}

// 认证动作
enum AuthAction: Action {
    case login(User)
    case logout
    case loginFailure(String)
}

// 图片处理动作
enum ImageAction: Action {
    case selectImage(UIImage?)
    case processImage(UIImage?)
    case selectImageModelType(ImageModelType)
    case processingFailure(String)
}

// 用户模型
struct User {
    let id: String
    let name: String
    let email: String
}

// 图片模型类型
struct ImageModelType {
    let id: String
    let name: String
    let description: String
    let isVipOnly: Bool
} 