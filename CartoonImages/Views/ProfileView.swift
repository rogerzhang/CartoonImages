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
    @State private var showMailView = false
    @State private var showMailErrorAlert = false
    
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
                            Text("APP_NAME".localized)
                                .font(.headline)
                            Text("VERSION".localized + " " + Bundle.version())
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
                        Label("RATE_US".localized, systemImage: "star")
                            .foregroundColor(themeManager.text)
                    }
                    
                    Button(action: { showShareSheet = true }) {
                        Label("SHARE".localized, systemImage: "square.and.arrow.up")
                            .foregroundColor(themeManager.text)
                    }
                }
                
                // Section 3: 客服
                Section {
                    Button(action: {
                        if MailHelper.canSendMail() {
                            showMailView = true
                        } else {
                            showContactSheet = true
                        }
                    }) {
                        Label("CONTACT_US".localized, systemImage: "message")
                            .foregroundColor(themeManager.text)
                    }
                }
                
                // 隐私和协议
                Section {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("PRIVACY_POLICY".localized, systemImage: "hand.raised")
                            .foregroundColor(themeManager.text)
                    }
                    
                    NavigationLink(destination: UserAgreementView()) {
                        Label("USER_AGREEMENT".localized, systemImage: "doc.text")
                            .foregroundColor(themeManager.text)
                    }
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings".localized, systemImage: "gearshape")
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
                ShareSheet(items: ["分享享文本内容", URL(string: "https://your-app-url.com")!])
            }
            .sheet(isPresented: $showMailView) {
                MailView(toRecipients: ["roger.zhangvi@gmail.com"],
                         subject: "[\("APP_NAME".localized)] \("COUSTOMER_SUPPORT".localized)",
                        messageBody: """
                        App Version: \(Bundle.version())
                        Device: \(UIDevice.current.model)
                        System Version: \(UIDevice.current.systemVersion)
                        
                        \("COUSTOMER_SUPPORT_DES".localized)
                        
                        """,
                        isBodyHTML: false)
            }
            .alert("CONTACT_US".localized, isPresented: $showContactSheet) {
                Button("COPY_WECHAT".localized, action: {
                    UIPasteboard.general.string = "FelixChen33"
                })
                Button("CANCEL".localized, role: .cancel) { }
            } message: {
                Text("CONTACT_INFO".localized)
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
