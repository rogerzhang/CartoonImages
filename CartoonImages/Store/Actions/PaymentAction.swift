import Foundation

enum PaymentAction {
    case startPayment(amount: Decimal)
    case paymentSuccess
    case paymentFailure(Error)
    case updatePaymentStatus(Bool)
    case dismissError
} 
