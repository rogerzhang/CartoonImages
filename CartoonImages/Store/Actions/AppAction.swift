import ReSwift

enum AppAction: Action {
    case auth(AuthAction)
    case image(ImageAction)
    case payment(PaymentAction)
} 