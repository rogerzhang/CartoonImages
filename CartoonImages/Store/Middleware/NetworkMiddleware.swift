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
                case .fetchHomeConfig:
                    NetworkService.shared.getHomeConfig()
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                dispatch(AppAction.auth(.fetchHomeConfigFailed(error: error)))
                            }
                        }, receiveValue: { effects in
                            dispatch(AppAction.auth(.fetchHomeConfigSuccess(config: effects)))
                        })
                        .store(in: &NetworkService.shared.cancellables)
                    
                default:
                    break
                }
                
            case let .image(imageAction):
                switch imageAction {
                case let .startProcessing(imageData, modelType):
                    dispatch(AppAction.image(.updateProcessingStatus(true)))
                    
                    NetworkService.shared.processImage(imageData, model: modelType)
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
                    break
                default:
                    break
                }
                
            case let .profile(profileAction):
                switch profileAction {
                case .startFetchAnnounce(let version):
                    NetworkService.shared.fetchAnnouncements(version)
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { completion in
                                if case let .failure(error) = completion {
                                    dispatch(AppAction.profile(.fetchAnnounceFailed(error)))
                                }
                            },
                            receiveValue: { annoucements in
                                dispatch(AppAction.profile(.fetchAnnounceSuccess(annoucements)))
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
