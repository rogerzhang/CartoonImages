import ReSwift

func authReducer(action: AuthAction, state: AuthState) -> AuthState {
    var newState = state
    
    switch action {
    case .login:
        newState.error = nil
        
    case let .loginSuccess(token):
        newState.isLoggedIn = true
        newState.token = token
        newState.error = nil
        
    case let .loginFailure(error):
        newState.isLoggedIn = false
        newState.token = nil
        newState.error = error
        
    case .logout:
        newState.isLoggedIn = false
        newState.token = nil
        newState.error = nil
    }
    
    return newState
} 
