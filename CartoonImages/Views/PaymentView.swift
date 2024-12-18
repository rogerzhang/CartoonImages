import SwiftUI

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

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: self.isSubscribed ? "crown.fill" : "crown")
                        .font(.system(size: 38))
                        .foregroundColor(self.isSubscribed ? .yellow : .gray)
                    VStack {
                        Text(self.isSubscribed ? "你是尊贵的会员" : "非会员")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if self.isSubscribed {
                            let dataString = PaymentService.shared.formartedExpirationDate()
                            Text("到期时间：" + dataString)
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
                    Text("会员状态")
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
                                Text("会员类型")
                                    .font(.system(size: 10))
                                    .foregroundColor(.init(hex: 0xEEA47D))
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.black)
                            .cornerRadius(15)
                            
                            Text(self.isSubscribed ? "已开通" : "未开通")
                                .font(.headline)
                            let leftDays = PaymentService.shared.expirationDaysFromToday()
                            Text(self.isSubscribed ? "会员还有\(leftDays)天到期" : "请升级到VIP")
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
            
            PaymentPlanView()
            
            VStack(spacing: 12) {
//                Divider()
//                    .padding(.vertical, 8)
                
                // 会员服务说明
                VStack(alignment: .leading, spacing: 8) {
                    Text("会员服务")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("无限次数处理图片")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("去除效果图片水印")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("及时更新和使用最新特效")
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
                            Text("立即开通")
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
            }
            .padding(.horizontal)
        }
        .alert("支付错误", isPresented: $showPaymentError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(paymentError ?? "未知错误")
        }
        .alert("恢复失败", isPresented: $showRestoreError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(restoreError ?? "未知错误")
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
                    await PaymentService.shared.updatePurchaseStatus(for: planType, transaction: transaction)
                    
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
