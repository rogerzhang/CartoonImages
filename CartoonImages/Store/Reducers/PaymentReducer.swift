import Foundation

func paymentReducer(action: PaymentAction, state: PaymentState) -> PaymentState {
    var newState = state
    
    switch action {
    case .startPayment:
        newState.isProcessing = true
        newState.error = nil
        newState.showError = false
        newState.lastTransactionId = nil
        
    case .paymentSuccess:
        newState.isProcessing = false
        newState.error = nil
        newState.showError = false
        
    case let .paymentFailure(error):
        newState.isProcessing = false
        newState.error = error.localizedDescription
        newState.showError = true
        
    case let .updatePaymentStatus(isProcessing):
        newState.isProcessing = isProcessing
        
    case .dismissError:
        newState.showError = false
        newState.error = nil
    }
    
    return newState
} 