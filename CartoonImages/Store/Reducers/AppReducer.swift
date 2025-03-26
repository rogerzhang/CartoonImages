import ReSwift

func appReducer(_ action: Action, _ state: AppState?) -> AppState {
    // 如果状态为空，返回初始状态
    var state = state ?? AppState()
    
    // 将 Action 转换为 AppAction
    guard let appAction = action as? AppAction else { return state }
    
    switch appAction {
    case let .auth(authAction):
        state.authState = authReducer(action: authAction, state: state.authState)
        
    case let .image(imageAction):
        state.imageState = imageReducer(action: imageAction, state: state.imageState)
        
    case let .payment(paymentAction):
        state.paymentState = paymentReducer(action: paymentAction, state: state.paymentState)
        
    case let .profile(profileAction):
        state.profileState = profileReducer(action: profileAction, state: state.profileState)
    }
    
    return state
} 
