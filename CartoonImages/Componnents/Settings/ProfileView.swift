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
    @EnvironmentObject var announcementViewModel: AnnouncementViewModel
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
                                .foregroundColor(themeManager.text)
                            Text("VERSION".localized + " " + Bundle.version())
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryText)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(themeManager.secondaryBackground)
                }
                
                // 公告
                Section {
                    NavigationLink(destination: AnnouncementView()) {
                        HStack {
                            Label("SETTINGS_ANNOUNCEMENT".localized, systemImage: "tray.full")
                                .foregroundColor(themeManager.text)
                            Spacer()
                            if announcementViewModel.hasUnread() {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackground)
                }
                
                // Section 2: 评分和分享
                Section {
                    Button(action: {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6739438626") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("RATE_US".localized, systemImage: "star")
                            .foregroundColor(themeManager.text)
                    }
                    .listRowBackground(themeManager.secondaryBackground)
                    
                    Button(action: { showShareSheet = true }) {
                        Label("SHARE".localized, systemImage: "square.and.arrow.up")
                            .foregroundColor(themeManager.text)
                    }
                    .listRowBackground(themeManager.secondaryBackground)
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
                    .listRowBackground(themeManager.secondaryBackground)
                }
                
                // 主题切换
                Section {
                    Toggle(isOn: Binding(
                        get: { themeManager.colorScheme == .dark },
                        set: { newValue in
                            themeManager.colorScheme = newValue ? .dark : .light
                        }
                    )) {
                        Label("DARK_MODE".localized, systemImage: "moon")
                            .foregroundColor(themeManager.text)
                    }
                    .listRowBackground(themeManager.secondaryBackground)
                }
                
                // 隐私和协议
                Section {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("PRIVACY_POLICY".localized, systemImage: "hand.raised")
                            .foregroundColor(themeManager.text)
                    }
                    .listRowBackground(themeManager.secondaryBackground)
                    
                    NavigationLink(destination: UserAgreementView()) {
                        Label("USER_AGREEMENT".localized, systemImage: "doc.text")
                            .foregroundColor(themeManager.text)
                    }
                    .listRowBackground(themeManager.secondaryBackground)
                    
                    #if DEBUG
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings".localized, systemImage: "gearshape")
                            .foregroundColor(themeManager.text)
                    }
                    .listRowBackground(themeManager.secondaryBackground)
                    #endif
                }
            }
            .listStyle(.insetGrouped)
            .background(themeManager.background)
            .scrollContentBackground(.hidden) // 隐藏默认背景
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLoginSheet) {
                VerificationLoginView()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: ["分享文本内容", URL(string: "https://apps.apple.com/us/app/toonyou/id6739438626")!])
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
            .actionSheet(isPresented: $showContactSheet) {
                ActionSheet(
                    title: Text("CONTACT_US".localized),
                    message: Text("CONTACT_INFO".localized),
                    buttons: [
                        .default(Text("COPY_WECHAT".localized)) {
                            UIPasteboard.general.string = "FelixChen33"
                        },
                        .cancel(Text("CANCEL".localized))
                    ]
                )
            }
        }
        .onAppear {
            let backButtonAppearance = UIBarButtonItem.appearance()
            backButtonAppearance.title = "Custom Back"
            
            // 自定义 UITableView 外观（iOS 16以下兼容）
            UITableView.appearance().backgroundColor = .clear
        }
        .environment(\.colorScheme, themeManager.colorScheme) // 可选：强制使用主题的颜色方案
    }
}
