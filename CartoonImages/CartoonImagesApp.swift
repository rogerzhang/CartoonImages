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
        }
    }
}
