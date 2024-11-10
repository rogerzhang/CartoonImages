import ReSwift
import Combine

let networkMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)
            
            // 确保 action 是 AppAction 类型
            guard let appAction = action as? AppAction else { return }
            
            switch appAction {
            case let .auth(authAction):
                switch authAction {
                case let .login(username, password):
                    // 处理登录请求
                    print("Processing login for user: \(username)")
                    // 这里添加实际的登录逻辑
                    
                case .logout:
                    // 处理登出请求
                    print("Processing logout")
                    // 这里添加实际的登出逻辑
                    
                default:
                    break
                }
                
            case let .image(imageAction):
                switch imageAction {
                case let .startProcessing(image, modelType):
                    dispatch(AppAction.image(.updateProcessingStatus(true)))
                    
                    NetworkService.shared.processImage(image, modelType: modelType)
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { completion in
                                dispatch(AppAction.image(.updateProcessingStatus(false)))
                                if case let .failure(error) = completion {
                                    dispatch(AppAction.image(.processFailure(error)))
                                }
                            },
                            receiveValue: { processedImage in
                                dispatch(AppAction.image(.processSuccess(processedImage)))
                            }
                        )
                        .store(in: &NetworkService.shared.cancellables)
                    
                default:
                    break
                }
                
            case let .payment(paymentAction):
                switch paymentAction {
                case let .startPayment(amount):
                    guard PaymentService.shared.canMakePayments() else {
                        dispatch(AppAction.payment(.paymentFailure(PaymentError.notAvailable)))
                        return
                    }
                    
                    dispatch(AppAction.payment(.updatePaymentStatus(true)))
                    
                    PaymentService.shared.processPayment(amount: amount)
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { completion in
                                dispatch(AppAction.payment(.updatePaymentStatus(false)))
                                if case let .failure(error) = completion {
                                    dispatch(AppAction.payment(.paymentFailure(error)))
                                }
                            },
                            receiveValue: { _ in
                                dispatch(AppAction.payment(.paymentSuccess))
                            }
                        )
                        .store(in: &NetworkService.shared.cancellables)
                    
                default:
                    break
                }
            }
        }
    }
}
