//
//  CartoonImagesApp.swift
//  CartoonImages
//
//  Created by roger on 2024/11/3.
//

import SwiftUI
import ReSwift

@main
struct CartoonImagesApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var networkManager = NetworkPermissionManager.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var interfaceStyle: ColorScheme = .dark

    init() {
        PushService.shared.setupPushNotifications()
        // 设置订阅状态变化的监听
        PaymentService.shared.onSubscriptionStatusChanged = { isPremium in
            mainStore.dispatch(AppAction.payment(.updateSubscriptionStatus(isPremium)))
        }
        
        let storedScheme = UserDefaults.standard.string(forKey: "colorScheme") ?? "light"
        interfaceStyle = (storedScheme == "dark") ? .dark : .light
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .alert("NETWORK_PERMISSION_TITLE".localized, isPresented: $networkManager.showNetworkAlert) {
                    Button("OK".localized) { }
                } message: {
                    Text("NETWORK_PERMISSION_MESSAGE".localized)
                }
                .preferredColorScheme(interfaceStyle)
        }
    }
}
