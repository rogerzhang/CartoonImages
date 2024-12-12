import SwiftUI

struct PaymentView: View {
    @Binding var showPaymentAlert: Bool
    @Binding var paymentIsProcessing: Bool
    @Binding var showPaymentError: Bool
    var paymentError: String?
    var handlePayment: (Decimal) -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State var isLoggedIn: Bool = false

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: isLoggedIn ? "person.circle.fill" : "person.circle")
                        .font(.system(size: 50))
                        .foregroundColor(themeManager.accent)
                    VStack {
                        Text("会飞的鱼")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("2025/12/05到期")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Image("viplogo")
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
                            
                            Text("已开通")
                                .font(.headline)
                            Text("会员还有9天到期")
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
                .padding(.vertical, 20)
                .background(Color.init(hex: 0xF8FFEC))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                                Color.init(hex: 0x6CEACF), lineWidth: 1)
                )
                
                Spacer()
                // 价格和支付按钮
                VStack(spacing: 10) {
//                    Text("¥1.99/月")
//                        .font(.title2)
//                        .fontWeight(.bold)
                    
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
                .padding(.bottom, 40)
            }
            .padding(.horizontal)
        }
      
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
