//
//  AppReducer.swift
//  CartoonImages
//
//  Created by roger on 2024/11/4.
//

import Foundation
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState.initialState()
    
    switch action {
    case let action as AppAction:
        switch action {
        case .auth(let authAction):
            state.authState = authReducer(action: authAction, state: state.authState)
        case .image(let imageAction):
            state.imageState = imageReducer(action: imageAction, state: state.imageState)
        case .subscription(let subscriptionAction):
            state.subscriptionState = subscriptionReducer(action: subscriptionAction, state: state.subscriptionState)
        }
    default:
        break
    }
    
    return state
}

func authReducer(action: AuthAction, state: AuthState) -> AuthState {
    var state = state
    
    switch action {
    case .login:
        state.error = nil
    case .loginSuccess(let user, let token):
        state.isLoggedIn = true
        state.currentUser = user
        state.token = token
        state.error = nil
    case .loginFailure(let error):
        state.isLoggedIn = false
        state.currentUser = nil
        state.token = nil
        state.error = error
    case .logout:
        state.isLoggedIn = false
        state.currentUser = nil
        state.token = nil
        state.error = nil
    }
    
    return state
}

func imageReducer(action: ImageAction, state: ImageState) -> ImageState {
    var state = state
    
    switch action {
    case .selectImage(let image):
        state.selectedImage = image
        state.error = nil
    case .startProcessing:
        state.isProcessing = true
        state.error = nil
    case .processSuccess(let image):
        state.processedImage = image
        state.isProcessing = false
        state.error = nil
    case .processFailure(let error):
        state.isProcessing = false
        state.error = error
    case .saveToLibrary:
        break
    }
    
    return state
}

func subscriptionReducer(action: SubscriptionAction, state: SubscriptionState) -> SubscriptionState {
    var state = state
    
    switch action {
    case .fetchProducts:
        state.error = nil
    case .purchaseProduct:
        state.isPurchasing = true
        state.error = nil
    case .purchaseSuccess:
        state.isPurchasing = false
        state.error = nil
    case .purchaseFailure(let error):
        state.isPurchasing = false
        state.error = error
    }
    
    return state
}
