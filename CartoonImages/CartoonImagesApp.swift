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
    
    init() {
        // 设置订阅状态变化的监听
        PaymentService.shared.onSubscriptionStatusChanged = { isPremium in
            mainStore.dispatch(AppAction.payment(.updateSubscriptionStatus(isPremium)))
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .alert("NETWORK_PERMISSION_TITLE".localized, isPresented: Binding<Bool>(
                    get: { !networkManager.isNetworkAuthorized },
                    set: { newValue in networkManager.isNetworkAuthorized = !newValue })) {
                    Button("OK".localized) { }
                } message: {
                    Text("NETWORK_PERMISSION_MESSAGE".localized)
                }
        }
    }
}
