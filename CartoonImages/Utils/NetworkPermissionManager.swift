import Foundation
import Network

class NetworkPermissionManager: ObservableObject {
    static let shared = NetworkPermissionManager()
    
    @Published var isNetworkAuthorized = false
    @Published var showNetworkAlert = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAuthorized = path.status == .satisfied
                
                // 如果是首次启动，显示网络权限提示
                if !UserDefaults.standard.bool(forKey: "hasShownNetworkPermission") {
                    self?.showNetworkAlert = true
                    UserDefaults.standard.set(true, forKey: "hasShownNetworkPermission")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
} 