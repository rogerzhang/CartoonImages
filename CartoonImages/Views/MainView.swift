import SwiftUI
import ReSwift

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
        ZStack(alignment: .top) {
            themeManager.background
                .ignoresSafeArea()
            
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
            .edgesIgnoringSafeArea(.top)
        }
        .sheet(isPresented: $showPayment) {
            PaymentView(
                showPaymentAlert: .constant(false),
                paymentIsProcessing: $viewModel.paymentIsProcessing,
                showPaymentError: .constant(false),
                isSubscribed: $viewModel.isSubscribed,
                paymentError: nil,
                handlePayment: {  }
            )
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
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
                    .font(.system(size: 44))
                    .foregroundColor(themeManager.accent)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())  // 添加这行以扩大点击区域
  
            
//            NavigationLink(destination: {
//                ProfileView()
//            }) {
//                Image("profiles")
//                    .font(.system(size: 44))
//                    .foregroundColor(themeManager.accent)
//            }
        }
        .frame(height: 44)  // 固定导航栏高度
    }
}

class MainViewModel: ObservableObject {
    @Published var modelTypes: [ImageModelType]?
    @Published var isSubscribed: Bool = false
    @Published var paymentIsProcessing: Bool = false
    
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
            self.isSubscribed = state.paymentState.isSubscribed
            self.paymentIsProcessing = state.paymentState.isProcessing
        }
    }
}

#Preview(body: {
    MainView()
})
