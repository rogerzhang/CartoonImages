import SwiftUI
import ReSwift

struct MainTextStyle: ViewModifier {
    @EnvironmentObject private var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(themeManager.text)
    }
}

struct SecondaryTextStyle: ViewModifier {
    @EnvironmentObject private var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(themeManager.secondaryText)
    }
}

struct PaymentView: View {
    @Binding var showPaymentAlert: Bool
    @Binding var paymentIsProcessing: Bool
    @Binding var showPaymentError: Bool
    @Binding var isSubscribed: Bool
    
    var paymentError: String?
    var handlePayment: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var isRestoringPurchases = false
    @State private var showRestoreError = false
    @State private var restoreError: String?
    @State var isLoggedIn: Bool = false
    @StateObject var viewModel: PaymentViewModel = .init()

    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    // 顶部订阅状态
                    HStack {
                        HStack {
                            Image(systemName: self.isSubscribed ? "crown.fill" : "crown")
                                .font(.system(size: 38))
                                .foregroundColor(self.isSubscribed ? .yellow : themeManager.secondaryText)
                            
                            VStack(alignment: .leading) {
                                Text(self.isSubscribed ? "SUBSCRIBED".localized : "NOT_SUBSCRIBED".localized)
                                    .font(.headline)
                                    .foregroundColor(themeManager.text)
                                
                                if self.isSubscribed {
                                    let dateString = PaymentService.shared.formartedExpirationDate()
                                    Text("EXPIRES_ON".localizedFormat(dateString))
                                        .font(.system(size: 14))
                                        .foregroundColor(themeManager.secondaryText)
                                } else {
                                    Text("UPGRADE_TO_VIP".localized)
                                        .font(.system(size: 14))
                                        .foregroundColor(themeManager.secondaryText)
                                }
                            }
                        }
                        Spacer()
                        Image("viplogo")
                    }
                    .padding(.horizontal)
                    
                    // 会员状态卡片
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("MEMBER_STATUS".localized)
                                .font(.headline)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.init(hex: 0xABED3B), .init(hex: 0x61DFC2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.bottom, 0)
                            
                            ZStack(alignment: .leading) {
                                Image("vipstate")
                                    .frame(width: 175, height: 114)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Image("diamon")
                                        Text("MEMBER_TYPE".localized)
                                            .font(.system(size: 10))
                                            .foregroundColor(.init(hex: 0xEEA47D))
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(themeManager.cardAccent)
                                    .cornerRadius(15)
                                    
                                    Text(self.isSubscribed ? "SUBSCRIBED".localized : "NOT_SUBSCRIBED".localized)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    let leftDays = PaymentService.shared.expirationDaysFromToday()
                                    Text(self.isSubscribed ? "DAYS_LEFT".localizedFormat(leftDays) : "UPGRADE_TO_VIP".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 5)
                            }
                            .padding(0)
                        }
                        .padding(.horizontal)
                        .padding(.top, 0)
                        .padding(.bottom, 20)
                        
                        Spacer()
                    }
                    
                    // 支付计划
                    VStack {
                        PaymentPlanView()
                            .frame(height: 120)
                    }
                    .padding(0)
                    .padding(.horizontal)
                    
                    // 计划描述
                    VStack {
                        switch viewModel.currentPaymentType {
                        case .monthly:
                            let product = mainStore.state.paymentState.products.first(where: { $0.productIdentifier == PaymentPlanType.monthly.rawValue})
                            let price = PaymentService.shared.localizedPrice(for: product!)
                            let text = "MONTHLY_PLAN_DES".localizedFormat(price!)
                            Text(text)
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryText)
                        case .weekly:
                            let product = mainStore.state.paymentState.products.first(where: { $0.productIdentifier == PaymentPlanType.weekly.rawValue})
                            let price = PaymentService.shared.localizedPrice(for: product!)
                            let text = "WEEKLY_PLAN_DES".localizedFormat(price!)
                            Text(text)
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryText)
                        case .yearly:
                            let product = mainStore.state.paymentState.products.first(where: { $0.productIdentifier == PaymentPlanType.yearly.rawValue})
                            let price = PaymentService.shared.localizedPrice(for: product!)
                            let text = "YEARLY_PLAN_DES".localizedFormat(price!)
                            Text(text)
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryText)
                        case .none:
                            Text("")
                                .font(.subheadline)
                        }
                    }
                    .padding(.top, 0)
                    .padding(.bottom, 10)
                    
                    // 会员权益和操作按钮
                    VStack(spacing: 12) {
                        // 会员权益
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MEMBER_BENEFITS".localized)
                                .font(.headline)
                                .foregroundColor(themeManager.text)
                            
                            ForEach(1...3, id: \.self) { index in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("BENEFIT_\(index)".localized)
                                        .foregroundColor(themeManager.text)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        .background(themeManager.benefitsBackground)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(themeManager.benefitsBorder, lineWidth: 1)
                        )
                        
                        Spacer()
                        
                        // 订阅按钮
                        VStack(spacing: 10) {
                            Button(action: {
                                guard let plan = mainStore.state.paymentState.selectedPlan else {
                                    fatalError("no selected plan")
                                }
                                mainStore.dispatch(AppAction.payment(.startPayment(plan)))
                            }) {
                                HStack {
                                    Image(systemName: "applelogo")
                                    Text("SUBSCRIBE_NOW".localized)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(themeManager.buttonBackground)
                                .foregroundColor(themeManager.buttonText)
                                .cornerRadius(10)
                            }
                            .disabled(paymentIsProcessing || isRestoringPurchases)
                        }
                        .padding(.horizontal)
                        
                        // 底部链接
                        HStack {
                            Button(action: {
                                restorePurchases()
                            }, label: {
                                Text("RESTORE_PURCHASES".localized)
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                                    .padding(.vertical)
                            })
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                let urlString = isZHansLanguage() ? "https://hk.holymason.cn/TermsAndConditionsZh.html" : "https://hk.holymason.cn/TermsAndConditionsEn.html"
                                Link("TERMS".localized, destination: URL(string: urlString)!)
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                                
                                let urlString1 = isZHansLanguage() ? "https://hk.holymason.cn/PrivacyPolicyZH.html" : "https://hk.holymason.cn/PrivacyPolicyEN.html"
                                Link("PRIVACY".localized, destination: URL(string: urlString1)!)
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // 加载指示器
            if paymentIsProcessing || isRestoringPurchases {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("PROCESSING".localized)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .frame(width: 120, height: 120)
                .background(themeManager.loadingBackground)
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
        .alert("PAYMENT_ERROR".localized, isPresented: $showPaymentError) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text(paymentError ?? "UNKNOWN_ERROR".localized)
                .foregroundColor(themeManager.text)
        }
        .alert("RESTORE_FAILED".localized, isPresented: $showRestoreError) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text(restoreError ?? "UNKNOWN_ERROR".localized)
                .foregroundColor(themeManager.text)
        }
    }
    
    private func isZHansLanguage() -> Bool {
        let preferredLanguages = Bundle.main.preferredLocalizations
        let language = preferredLanguages.first ?? "en"
        return language.starts(with: "zh")
    }
    
    private func restorePurchases() {
        isRestoringPurchases = true
        
        Task {
            do {
                try await PaymentService.shared.restorePurchases()
                await MainActor.run {
                    isRestoringPurchases = false
//                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isRestoringPurchases = false
                    restoreError = error.localizedDescription
                    showRestoreError = true
                }
            }
        }
    }
    
    private func handlePurchase(planType: PaymentPlanType) {
        Task {
            do {
                paymentIsProcessing = true
                
                // 先加载产品
                try await PaymentService.shared.loadProducts()
                
                // 执行购买
                if let transaction = try await PaymentService.shared.purchase(planType) {
                    // 更新购买状态
                    PaymentService.shared.updatePurchaseStatus(for: planType, transaction: transaction)
                    
                    await MainActor.run {
                        paymentIsProcessing = false
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    paymentIsProcessing = false
                    showPaymentError = true
                    // 使用 error.localizedDescription 显示错误信息
                }
            }
        }
    }
}

class PaymentViewModel: ObservableObject {
    @Published var currentPaymentType: PaymentPlanType?
    
    init() {
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                (state.paymentState)
            }
        }
    }
}

extension PaymentViewModel: StoreSubscriber {
    func newState(state: (PaymentState)) {
        DispatchQueue.main.async {
            self.currentPaymentType = state.selectedPlan
        }
    }
}
