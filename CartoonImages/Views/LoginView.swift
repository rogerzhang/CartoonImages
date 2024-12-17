import SwiftUI
import ReSwift
import Combine

struct LoginView1: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Login") {
                viewModel.login()
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct VerificationLoginView: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var isAgreementChecked: Bool = false

    var body: some View {
        VStack {
            // 背景和Logo部分
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.orange.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("image2") // 替换为实际 Logo 图片名称
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text("卡通化")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.top, 80)
            }
            .frame(height: 200)
            
            // 表单内容部分
            VStack(spacing: 16) {
                // 手机号输入框
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.gray)
                    TextField("手机号", text: $phoneNumber)
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                
                // 验证码输入框
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    TextField("验证码", text: $verificationCode)
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        // 发送验证码逻辑
                    }) {
                        Text("发送")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pink, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                
                // 用户协议勾选框
                HStack {
                    Button(action: {
                        isAgreementChecked.toggle()
                    }) {
                        Image(systemName: isAgreementChecked ? "checkmark.square.fill" : "square")
                            .foregroundColor(isAgreementChecked ? .blue : .gray)
                    }
                    
                    Text("请阅读并同意")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        // 跳转到服务协议页面
                    }) {
                        Text("《服务协议》")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        // 跳转到隐私政策页面
                    }) {
                        Text("《隐私政策》")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
                
                // 登录按钮
                Button(action: {
                    // 登录逻辑
                }) {
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isAgreementChecked ? [Color.pink, Color.orange] : [Color.gray.opacity(0.5), Color.gray.opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .disabled(!isAgreementChecked)
                .padding(.top, 16)
            }
            .padding()
            .background(.clear)
            
            Spacer()
            
            // 底部切换选项
            VStack {
                Button(action: {
                    // 跳转到邮箱登录
                }) {
                    Text("邮箱登录")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    // 跳转到注册页面
                }) {
                    Text("注册")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct VerificationLoginView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationLoginView()
    }
}

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isRegister: Bool = false // 登录或注册模式

    var body: some View {
        VStack {
            // 背景图片和Logo
            ZStack {
                Image("bg_login") // 替换为实际背景图片名称
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)

                Image("image2") // 替换为实际Logo图片名称
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, 60)
            }
            .frame(height: 200)

            Spacer()

            // 表单内容
            VStack(spacing: 20) {
                // 手机号输入框
                TextField("请输入手机号", text: $phoneNumber)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)

                // 验证码或密码输入框
                if isRegister {
                    // 注册模式
                    SecureField("请输入密码", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)

                    SecureField("请确认密码", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                } else {
                    // 登录模式
                    TextField("请输入验证码", text: $verificationCode)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                }

                // 操作按钮
                Button(action: {
                    // 按钮操作逻辑
                }) {
                    Text(isRegister ? "注册" : "登录")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // 辅助选项
                HStack {
                    Button("忘记密码？") {
                        // 忘记密码操作
                    }
                    Spacer()
                    Button(isRegister ? "已有账号？登录" : "没有账号？注册") {
                        isRegister.toggle()
                    }
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        isLoading = true
        error = nil
        mainStore.dispatch(AppAction.auth(.login(username: username, password: password)))
    }
    
    init() {
        // 监听状态变化
        mainStore.subscribe(self)
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
}

extension LoginViewModel: StoreSubscriber {
    func newState(state: AppState) {
        isLoading = false // 当收到新状态时重置loading
        if let error = state.authState.error {
            self.error = error
        }
    }
} 
