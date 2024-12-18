import SwiftUI

struct CustomLabelStyle: LabelStyle {
    var imageColor: Color
    var textColor: Color
    var fontSize: CGFloat = 20
    var spacing: CGFloat = 15

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
                .foregroundColor(imageColor)
                .font(.system(size: fontSize)) // 设置图标大小
            configuration.title
                .foregroundColor(textColor)
                .font(.system(size: 17)) // 设置文字大小
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    
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
                Section {
                    HStack {
                        Image("image2")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading) {
                            Text("画影")
                                .font(.headline)
                            Text("版本 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryText)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Section 2: 评分和分享
                Section {
                    Button(action: {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("给我们评分", systemImage: "star")
//                            .labelStyle(CustomLabelStyle(imageColor: themeManager.accent, textColor: themeManager.text))
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
                        Label("联系客服", systemImage: "message")
                            .foregroundColor(themeManager.text)
                    }
                }
                
                // 隐私和协议
                Section {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("隐私政策", systemImage: "hand.raised")
                            .foregroundColor(themeManager.text)
                    }
                    
                    NavigationLink(destination: UserAgreementView()) {
                        Label("用户协议", systemImage: "doc.text")
                            .foregroundColor(themeManager.text)
                    }
                }
            }
//            .navigationTitle("个人中心")
            .sheet(isPresented: $showLoginSheet) {
//                LoginView()
                VerificationLoginView()
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
        .onAppear {
            let backButtonAppearance = UIBarButtonItem.appearance()
            backButtonAppearance.title = "Custom Back"
        }
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    HStack {
//                        Image(systemName: "chevron.backward")
//                        Text("个人中心")
//                    }
//                }
//            }
//        }
    }
} 
