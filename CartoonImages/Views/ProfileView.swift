import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showLoginSheet = false
    @State private var showSettingsView = false
    @State private var showShareSheet = false
    @State private var showContactSheet = false
    
    // 从 Store 获取登录状态和会员状态
    @State private var isLoggedIn = false
    @State private var isVipMember = false
    
    var body: some View {
        NavigationView {
            List {
                // Section 1: 用户信息
                Section {
                    Button(action: { showLoginSheet = true }) {
                        HStack {
                            Image(systemName: isLoggedIn ? "person.circle.fill" : "person.circle")
                                .font(.system(size: 50))
                                .foregroundColor(themeManager.accent)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(isLoggedIn ? "用户名" : "点击登录")
                                        .font(.headline)
                                    if isVipMember {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                    }
                                }
                                if isLoggedIn {
                                    Text("VIP会员")
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryText)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.secondaryText)
                        }
                    }
                }
                
                // Section 2: 评分和分享
                Section {
                    Button(action: {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("给我们评分", systemImage: "star.fill")
                            .foregroundColor(themeManager.text)
                    }
                    
                    Button(action: { showShareSheet = true }) {
                        Label("分享给好友", systemImage: "square.and.arrow.up")
                            .foregroundColor(themeManager.text)
                    }
                }
                
                // Section 3: 客服
                Section {
                    Button(action: { showContactSheet = true }) {
                        Label("联系客服", systemImage: "message.fill")
                            .foregroundColor(themeManager.text)
                    }
                }
                
                // Section 4: 设置
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("设置", systemImage: "gear")
                            .foregroundColor(themeManager.text)
                    }
                }
            }
            .navigationTitle("个人中心")
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: ["分享文本内容", URL(string: "https://your-app-url.com")!])
            }
            .alert("联系客服", isPresented: $showContactSheet) {
                Button("复制客服微信", action: {
                    UIPasteboard.general.string = "客服微信号"
                })
                Button("取消", role: .cancel) { }
            } message: {
                Text("客服微信号：YOUR_WECHAT_ID\n工作时间：9:00-18:00")
            }
        }
    }
} 