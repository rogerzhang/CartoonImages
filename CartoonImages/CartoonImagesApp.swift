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
        }
    }
}
