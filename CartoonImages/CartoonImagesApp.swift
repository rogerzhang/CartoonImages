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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .onAppear {
                    // 获取系统当前的颜色模式
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        themeManager.updateColorScheme(windowScene.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
                    }
                }
        }
    }
}
