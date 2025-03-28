//
//  AppDelegate.swift
//  CartoonImages
//
//  Created by roger on 2025/3/27.
//


import UIKit
import Combine

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("APNs 设备 Token: \(tokenString)")
        
        PushService.shared.registerDeviceToken(tokenString)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("注册 APNs 失败: \(error.localizedDescription)")
    }
}
