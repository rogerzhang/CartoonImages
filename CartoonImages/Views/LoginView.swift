import SwiftUI
import ReSwift
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Login") {
                viewModel.login()
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        isLoading = true
        error = nil
        mainStore.dispatch(AppAction.auth(.login(username: username, password: password)))
    }
    
    init() {
        // 监听状态变化
        mainStore.subscribe(self)
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
}

extension LoginViewModel: StoreSubscriber {
    func newState(state: AppState) {
        isLoading = false // 当收到新状态时重置loading
        if let error = state.authState.error {
            self.error = error
        }
    }
} 
