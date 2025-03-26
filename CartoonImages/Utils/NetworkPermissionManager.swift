import Foundation
import Network
import Combine

class NetworkPermissionManager: ObservableObject {
    static let shared = NetworkPermissionManager()
    
    @Published var isNetworkAuthorized = false
    @Published var showNetworkAlert = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAuthorized = path.status == .satisfied
                
                // 如果是首次启动，显示网络权限提示
                if !UserDefaults.standard.bool(forKey: "hasShownNetworkPermission") {
                    self?.showNetworkAlert = true
                    UserDefaults.standard.set(true, forKey: "hasShownNetworkPermission")
                } else {
                    self?.showNetworkAlert = false
                }
            }
        }
        monitor.start(queue: queue)
        
        setupNetworkAuthorizationObserver()
    }
    
    private func setupNetworkAuthorizationObserver() {
        $isNetworkAuthorized
            .removeDuplicates() // 只在状态变化时触发
            .filter { $0 } // 仅当 `isNetworkAuthorized == true` 触发
            .sink { _ in
                mainStore.dispatch(AppAction.auth(.fetchHomeConfig))
            }
            .store(in: &cancellables)
    }
    
    deinit {
        monitor.cancel()
    }
} 
