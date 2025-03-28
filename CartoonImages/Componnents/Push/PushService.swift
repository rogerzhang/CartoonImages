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
    
    func registerDeviceToken(_ token: String) {
        // 发送 Token 到服务器
        NetworkService.shared.registerTokenWithServer(token)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("推送 Token 注册请求完成")
                case .failure(let error):
                    print("推送 Token 注册失败: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                print("推送 Token 注册成功: \(response)")
            })
            .store(in: &NetworkService.shared.cancellables)
    }
}
