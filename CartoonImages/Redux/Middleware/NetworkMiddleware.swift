import Foundation
import StoreKit
import ReSwift
import Combine

class NetworkMiddleware {
    private var cancellables = Set<AnyCancellable>()
    
    func middleware() -> Middleware<AppState> {
        return { dispatch, getState in
            return { next in
                return { action in
                    // 先执行原始action
                    next(action)
                    
                    switch action {
                    case let authAction as AppAction:
                        switch authAction {
                        case .auth(.login(let username, let password)):
                            NetworkService.shared.login(username: username, password: password)
                                .receive(on: DispatchQueue.main)
                                .sink(
                                    receiveCompletion: { completion in
                                        if case let .failure(error) = completion {
                                            dispatch(AppAction.auth(.loginFailure(error)))
                                        }
                                    },
                                    receiveValue: { user in
                                        dispatch(AppAction.auth(.loginSuccess(user, "token")))
                                    }
                                )
                                .store(in: &self.cancellables)
                            
                        default:
                            break
                        }
                        
                    case let imageAction as AppAction:
                        switch imageAction {
                        case .image(.startProcessing):
                            if let image = getState()?.imageState.selectedImage {
                                NetworkService.shared.processImage(image)
                                    .receive(on: DispatchQueue.main)
                                    .sink(
                                        receiveCompletion: { completion in
                                            if case let .failure(error) = completion {
                                                dispatch(AppAction.image(.processFailure(error)))
                                            }
                                        },
                                        receiveValue: { processedImage in
                                            dispatch(AppAction.image(.processSuccess(processedImage)))
                                        }
                                    )
                                    .store(in: &self.cancellables)
                            }
                            
                        default:
                            break
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
    }
}
