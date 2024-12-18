import Foundation
import ReSwift
import StoreKit

enum PaymentAction: Action {
    case startPayment(PaymentPlanType)
    case paymentSuccess
    case paymentFailure(Error)
    case updateSubscriptionStatus(Bool)
    case selectPlan(PaymentPlanType?)
    case updateProcessingStep(Int)
    case updateProducts([SKProduct])
}
