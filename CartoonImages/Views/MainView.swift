import SwiftUI
import ReSwift

extension View {
    /// 一个自定义modifier简化 navigationLink 的书写
    func navigationLink<Destination: View>(
        destination: @escaping () -> Destination,
        isActive: Binding<Bool>
    ) -> some View {
        background(
            NavigationLink(
                destination: destination(),
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }
}

struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showProfile = false
    @State private var showPayment = false
    @State private var selectedModelId: String?
    @State private var selectedImage: UIImage?
    
    @StateObject var viewModel: MainViewModel = .init()
    
    // 示例数据
    private let carouselImages = ["banner1", "banner2", "banner3"]
    
    private lazy var modelTypes = {
        mainStore.state.imageState.modelTypes
    }()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 背景色
                themeManager.background
                    .ignoresSafeArea()
                
                // 主要内容
                VStack(spacing: 0) {
                    // 固定在顶部的导航栏
                    topNavigationBar
                        .padding(.horizontal)
                        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                        .background(themeManager.background.opacity(0.98))
                        .zIndex(1)  // 确保导航栏在最上层
                    
                    // 滚动内容
                    ScrollView {
                        VStack(spacing: 20) {
                            CarouselView(images: carouselImages)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .padding()
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Features")
                                        .font(.headline)
                                        .foregroundColor(themeManager.text)
                                        .padding(.vertical, 0)
                                        .padding(.horizontal, 20)
                                    Spacer()
                                }
                                if let modelTypes = viewModel.modelTypes {
                                    ModelGridView(models: modelTypes) { model in
                                        selectedModelId = model.id
                                        mainStore.dispatch(AppAction.image(.selectImageModelType(model)))
                                    }
                                    .background(
                                        NavigationLink(
                                            destination: Group {
                                                if let modelId = selectedModelId {
                                                    let viewModel = ImageProcessingViewModel(initialModelId: modelId)
                                                    ImageProcessingView(viewModel: viewModel)
                                                } else {
                                                    EmptyView()
                                                }
                                            },
                                            isActive: Binding(
                                                get: { selectedModelId != nil },
                                                set: { if !$0 { selectedModelId = nil } }
                                            )
                                        ) {
                                            EmptyView()
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)  // 忽略顶部安全区域
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showPayment) {
            PaymentView(
                showPaymentAlert: .constant(false),
                paymentIsProcessing: .constant(false),
                showPaymentError: .constant(false),
                paymentError: nil,
                handlePayment: { _ in }
            )
        }
    }
    
    // 顶部导航栏
    private var topNavigationBar: some View {
        HStack {
            Button {
                showPayment = true
            } label: {
                ZStack {
                    Image("vip")
                    Text("   VIP")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.text)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())  // 添加这行以扩大点击区域
            
            Spacer()
            
            Button {
                showProfile = true
            } label: {
                Image("profiles")
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.accent)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())  // 添加这行以扩大点击区域
        }
        .frame(height: 44)  // 固定导航栏高度
    }
}

class MainViewModel: ObservableObject {
    @Published var modelTypes: [ImageModelType]?
    
    init() {
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                (state.imageState, state.paymentState)
            }
        }
    }
}

extension MainViewModel: StoreSubscriber {
    func newState(state: (imageState: ImageState, paymentState: PaymentState)) {
        DispatchQueue.main.async {
            self.modelTypes = state.imageState.modelTypes
        }
    }
}

#Preview(body: {
    MainView()
})
