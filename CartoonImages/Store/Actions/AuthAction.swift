enum AuthAction {
    case fetchHomeConfig
    case fetchHomeConfigSuccess(config: [ImageProcessingEffect])
    case fetchHomeConfigFailed(error: NetworkError)
    case login(username: String, password: String)
    case loginSuccess(token: String)
    case loginFailure(error: String)
    case logout
}
