//
//  PushService.swift
//  CartoonImages
//
//  Created by roger on 2025/3/27.
//

import Foundation
import SwiftUI
import UserNotifications

class PushService {
    static let shared = PushService()
    
    /// 注册推送通知
    func setupPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("用户拒绝了推送通知授权: \(error?.localizedDescription ?? "未知错误")")
            }
        }
        
        center.delegate = NotificationDelegate.shared
    }
}
