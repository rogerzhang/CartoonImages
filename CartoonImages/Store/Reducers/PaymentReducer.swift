import ReSwift
import StoreKit

// 如果 PaymentState 和 PaymentAction 已经在其他地方声明，
// 我们只需要实现 reducer 部分

func paymentReducer(action: Action, state: PaymentState?) -> PaymentState {
    var state = state ?? PaymentState()
    
    guard let action = action as? PaymentAction else { return state }
    
    switch action {
    case .startPayment(let planType):
        state.isProcessing = true
        state.error = nil
        state.selectedPlan = planType
        
        Task {
            do {
                try await PaymentService.shared.loadProducts()
                
                if (try await PaymentService.shared.purchase(planType)) != nil {
                    // 购买成功
                    await MainActor.run {
                        mainStore.dispatch(AppAction.payment(.paymentSuccess))
                    }
                }
            } catch {
                await MainActor.run {
                    mainStore.dispatch(AppAction.payment(.paymentFailure(error)))
                }
            }
        }
        
    case .paymentSuccess:
        state.isProcessing = false
        state.error = nil
        state.isSubscribed = true
        
    case .paymentFailure(let error):
        state.isProcessing = false
        state.error = error.localizedDescription
        state.isSubscribed = false
        
    case .updateSubscriptionStatus(let isSubscribed):
        logInfo("updateSubscriptionStatus: \(isSubscribed)")
        state.isSubscribed = isSubscribed
        
    case .selectPlan(let plan):
        state.selectedPlan = plan
        
    case .updateProcessingStep(let step):
        state.processingStep = step
    case .updateProducts(let products):
        state.products = products
    }
    
    return state
} 
