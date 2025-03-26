import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAccountAlert = false
    @State private var showLogs = false
    
    var body: some View {
        List {
            // Header Section
            Section {
                HStack {
                    Image("image2")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text("APP_NAME".localized)
                            .font(.headline)
                        Text("VERSION".localized)
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 隐私和协议
            Section {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("PRIVACY_POLICY".localized, systemImage: "hand.raised.fill")
                }
                
                NavigationLink(destination: UserAgreementView()) {
                    Label("USER_AGREEMENT".localized, systemImage: "doc.text.fill")
                }
            }
            
            // 账号相关
            Section {
                Button(action: { showDeleteAccountAlert = true }) {
                    Label("DELETE_ACCOUNT".localized, systemImage: "person.crop.circle.badge.minus")
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    mainStore.dispatch(AppAction.auth(.logout))
                }) {
                    Label("LOGOUT".localized, systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
            
            // 调试部分（仅在 DEBUG 模式下显示）
//            #if DEBUG
            Section("Debug") {
                Button(action: { showLogs = true }) {
                    Label("View Logs", systemImage: "doc.text.magnifyingglass")
                }
                
                Button(action: { Logger.shared.clearLogs() }) {
                    Label("Clear Logs", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
//            #endif
        }
        .navigationTitle("SETTINGS".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("DELETE_ACCOUNT_CONFIRM".localized, isPresented: $showDeleteAccountAlert) {
            Button("CANCEL".localized, role: .cancel) { }
            Button("CONFIRM_DELETE".localized, role: .destructive) {
                // 执行注销账号操作
            }
        } message: {
            Text("DELETE_ACCOUNT_WARNING".localized)
        }
        .sheet(isPresented: $showLogs) {
            NavigationView {
                ScrollView {
                    Text(Logger.shared.getLogContent())
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                .navigationTitle("Debug Logs")
                .navigationBarItems(trailing: Button("Done") { showLogs = false })
            }
        }
    }
}

// 隐私政策视图
struct PrivacyPolicyView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView {
            Text(loadPrivacyPolicy())
                .foregroundColor(themeManager.text)
                .padding()
        }
        .navigationTitle("PRIVACY_POLICY".localized)
        .background(themeManager.background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(themeManager.text)
                }
            }
        }
    }
    
    func loadPrivacyPolicy() -> String {
        let preferredLanguages = Bundle.main.preferredLocalizations
        let language = preferredLanguages.first ?? "en"
        let fileName = language.starts(with: "zh") ? "PrivacyPolicy_zh" : "PrivacyPolicy_en"

        if let path = Bundle.main.path(forResource: fileName, ofType: "txt", inDirectory: nil, forLocalization: language) {
            if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                return content
            }
        }
        
        return "Privacy Policy not available."
    }
}

// 用户协议视图
struct UserAgreementView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView {
            Text(loadPrivacyPolicy())
                .foregroundColor(themeManager.text)
                .padding()
        }
        .navigationTitle("USER_AGREEMENT".localized)
        .background(themeManager.background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(themeManager.text)
                }
            }
        }
    }
    
    func loadPrivacyPolicy() -> String {
        let preferredLanguages = Bundle.main.preferredLocalizations
        let language = preferredLanguages.first ?? "en"        
        let fileName = language.starts(with: "zh") ? "UserAgreement_zh" : "UserAgreement_en"

        if let path = Bundle.main.path(forResource: fileName, ofType: "txt", inDirectory: nil, forLocalization: language) {
            if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                return content
            }
        }
        
        return "User Agreement not available."
    }
}
