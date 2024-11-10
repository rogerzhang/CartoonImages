enum AuthAction {
    case login(username: String, password: String)
    case loginSuccess(token: String)
    case loginFailure(error: String)
    case logout
}
