import SwiftUI
import ReSwift

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            MainView()
//            if viewModel.isLoggedIn {
//                MainView()
//            } else {
//                LoginView()
//            }
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    init() {
        mainStore.subscribe(self) { subscription in
            subscription.select { state in state.authState.isLoggedIn }
        }
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
}

extension ContentViewModel: StoreSubscriber {
    func newState(state: Bool) {
        isLoggedIn = state
    }
} 
