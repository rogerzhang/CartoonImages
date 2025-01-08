import SwiftUI
import ReSwift

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
            ScrollView {
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: self.isSubscribed ? "crown.fill" : "crown")
                                .font(.system(size: 38))
                                .foregroundColor(self.isSubscribed ? .yellow : .gray)
                            VStack {
                                Text(self.isSubscribed ? "SUBSCRIBED".localized : "NOT_SUBSCRIBED".localized)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                if self.isSubscribed {
                                    let dataString = PaymentService.shared.formartedExpirationDate()
                                    Text("EXPIRES_ON".localizedFormat(dataString))
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("UPGRADE_TO_VIP".localized)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.leading, 20)
                        Spacer()
                        
                        Image("viplogo")
                            .padding(.trailing, 20)
                    }
                    
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
                                    .background(Color.black)
                                    .cornerRadius(15)
                                    
                                    Text(self.isSubscribed ? "SUBSCRIBED".localized : "NOT_SUBSCRIBED".localized)
                                        .font(.headline)
                                    let leftDays = PaymentService.shared.expirationDaysFromToday()
                                    Text(self.isSubscribed ? "DAYS_LEFT".localizedFormat(leftDays) : "UPGRADE_TO_VIP".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 5)
                            }
                            .padding(0)
                            .background(.clear)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                        .padding(.bottom, 20)
                        Spacer()
                    }
                    
                    VStack {
                        PaymentPlanView()
                            .frame(height: 120)
                    }.padding(0)
                    
                    VStack {
                        switch viewModel.currentPaymentType {
                        case .monthly:
                            let product = mainStore.state.paymentState.products.first(where: { $0.productIdentifier == PaymentPlanType.monthly.rawValue})
                            let price = PaymentService.shared.localizedPrice(for: product!)
                            let text = "MONTHLY_PLAN_DES".localizedFormat(price!)
                            Text(text)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        case .weekly:
                            let product = mainStore.state.paymentState.products.first(where: { $0.productIdentifier == PaymentPlanType.weekly.rawValue})
                            let price = PaymentService.shared.localizedPrice(for: product!)
                            let text = "WEEKLY_PLAN_DES".localizedFormat(price!)
                            Text(text)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        case .yearly:
                            let product = mainStore.state.paymentState.products.first(where: { $0.productIdentifier == PaymentPlanType.yearly.rawValue})
                            let price = PaymentService.shared.localizedPrice(for: product!)
                            let text = "YEARLY_PLAN_DES".localizedFormat(price!)
                            Text(text)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        case .none:
                            let text = ""
                            Text(text)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                    .padding(.top, 0)
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 12) {
        //                Divider()
        //                    .padding(.vertical, 8)
                        
                        // 会员服务说明
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MEMBER_BENEFITS".localized)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("BENEFIT_1".localized)
                            }
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("BENEFIT_2".localized)
                            }
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("BENEFIT_3".localized)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        .background(Color.init(hex: 0xF8FFEC))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(
                                        Color.init(hex: 0x6CEACF), lineWidth: 1)
                        )
                        
                        Spacer()
                 
                        
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
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(paymentIsProcessing)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                        
                        HStack {
                            Button(action: {
                                Task {
                                    paymentIsProcessing = true
                                    do {
                                        try await PaymentService.shared.restorePurchases()
                                    } catch {
                                    }
                                    paymentIsProcessing = false
                                }
                            }, label: {
                                Text("RESTORE_PURCHASES".localized)
                                    .font(.caption)
                                    .padding()
                            })
                            Spacer()
                            HStack(spacing: 20) {
                                Link("TERMS".localized, destination: URL(string: "https://hk.holymason.cn/TermsAndConditionsEn.html")!)
                                    .font(.caption)
                                Link("PRIVACY".localized, destination: URL(string: "https://hk.holymason.cn/PrivacyPolicyEN.html")!)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            
            if paymentIsProcessing {
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
                .background(.black.opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
  
        .alert("PAYMENT_ERROR".localized, isPresented: $showPaymentError) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text(paymentError ?? "UNKNOWN_ERROR".localized)
        }
        .alert("RESTORE_FAILED".localized, isPresented: $showRestoreError) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text(restoreError ?? "UNKNOWN_ERROR".localized)
        }
    }
    
    private func restorePurchases() {
        isRestoringPurchases = true
        
        Task {
            do {
                try await PaymentService.shared.restorePurchases()
                await MainActor.run {
                    isRestoringPurchases = false
                    dismiss()
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
