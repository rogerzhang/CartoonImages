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
        
        // 发送 Token 到服务器
        NetworkService.shared.registerTokenWithServer(tokenString)
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

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("注册 APNs 失败: \(error.localizedDescription)")
    }
}
