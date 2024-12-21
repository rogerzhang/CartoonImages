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
        .navigationTitle("隐私政策")
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
        if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
            return (try? String(contentsOfFile: path)) ?? "Privacy Policy not available."
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
        .navigationTitle("用户协议")
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
        if let path = Bundle.main.path(forResource: "UserAgreement", ofType: "txt") {
            return (try? String(contentsOfFile: path)) ?? "UserAgreement not available."
        }
        return "UserAgreement not available."
    }
}
