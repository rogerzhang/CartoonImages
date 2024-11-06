class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        isLoading = true
        error = nil
        
        NetworkService.shared.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.error = error.localizedDescription
                        mainStore.dispatch(AppAction.auth(.loginFailure(error)))
                    }
                },
                receiveValue: { user in
                    mainStore.dispatch(AppAction.auth(.loginSuccess(user, "token")))
                }
            )
            .store(in: &cancellables)
    }
} 