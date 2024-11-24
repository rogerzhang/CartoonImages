import SwiftUI

struct PaymentView: View {
    @Binding var showPaymentAlert: Bool
    @Binding var paymentIsProcessing: Bool
    @Binding var showPaymentError: Bool
    var paymentError: String?
    var handlePayment: (Decimal) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.vertical, 8)
            
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
                    Text("高级滤镜效果")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("批量处理功能")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // 价格和支付按钮
            VStack(spacing: 10) {
                Text("¥1.99/月")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button(action: {
                    showPaymentAlert = true
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
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
        .alert("确认支付", isPresented: $showPaymentAlert) {
            Button("确认") {
                if let amount = Decimal(string: "1.99") {
                    handlePayment(amount)
                }
                showPaymentAlert = false
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("开通会员服务 ¥1.99/月")
        }
        .alert("支付错误", isPresented: $showPaymentError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(paymentError ?? "未知错误")
        }
    }
} 