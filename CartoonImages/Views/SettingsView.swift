import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        List {
            // Header Section
            Section {
                HStack {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text("卡通化")
                            .font(.headline)
                        Text("版本 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 隐私和协议
            Section {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("隐私政策", systemImage: "hand.raised.fill")
                }
                
                NavigationLink(destination: UserAgreementView()) {
                    Label("用户协议", systemImage: "doc.text.fill")
                }
            }
            
            // 账号相关
            Section {
                Button(action: { showDeleteAccountAlert = true }) {
                    Label("注销账号", systemImage: "person.crop.circle.badge.minus")
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    // 执行登出操作
                    mainStore.dispatch(AppAction.auth(.logout))
                }) {
                    Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认注销账号", isPresented: $showDeleteAccountAlert) {
            Button("取消", role: .cancel) { }
            Button("确认注销", role: .destructive) {
                // 执行注销账号操作
            }
        } message: {
            Text("注销账号后，所有数据将被清除且无法恢复")
        }
    }
}

// 隐私政策视图
struct PrivacyPolicyView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            Text("隐私政策内容...")
                .foregroundColor(themeManager.text)
                .padding()
        }
        .navigationTitle("隐私政策")
        .background(themeManager.background)
    }
}

// 用户协议视图
struct UserAgreementView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            Text("用户协议内容...")
                .foregroundColor(themeManager.text)
                .padding()
        }
        .navigationTitle("用户协议")
        .background(themeManager.background)
    }
} 
