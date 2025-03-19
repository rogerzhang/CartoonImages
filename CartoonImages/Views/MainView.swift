import SwiftUI
import ReSwift

struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showProfile = false
    @State private var showPayment = false
    @State private var selectedModelId: Int?
    @State private var selectedSectionTitle: String?
    @State private var selectedImage: UIImage?
    @State private var showModelGridView = false
    @State private var modelGridEffects: [ImageProcessingEffect] = []
    
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
                        if let images = viewModel.headerImages, images.count > 0 {
                            CarouselView(images: images)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .padding()
                        }
                
                        VStack(spacing: 0) {
                            if let modelTypes = viewModel.config?.groupedBySortedRegion() {
                                VStack {
                                    ForEach(modelTypes, id: \.region) { section in
                                        ImageProcessingEffectSectionView(item: section, onModelSelected: { model in
                                            selectedModelId = model.id
                                            mainStore.dispatch(AppAction.image(.selectImageModelType(model)))
                                        }, onMoreBtnSelected: { effects in
                                            selectedSectionTitle = LocalizationManager.shared.currentLanguage == .chinese ? section.region_title_zh : section.region_title
                                            
                                            selectedModelId = nil
                                            showModelGridView = true
                                            modelGridEffects = effects
                                        })
                                    }
                                }
                                .background(navigationLinkToImageProcessingView())
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
        .background(navigationLinkToModelGridView())
    }
    
    private func navigationLinkToImageProcessingView() -> some View {
        NavigationLink(
            destination: Group {
                let viewModel = ImageProcessingViewModel()
                ImageProcessingView(viewModel: viewModel)
            },
            isActive: Binding(
                get: { selectedModelId != nil },
                set: { if !$0 { selectedModelId = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    private func navigationLinkToModelGridView() -> some View {
        NavigationLink(
            destination: ModelGridView(models: modelGridEffects, title: selectedSectionTitle ?? "", onModelSelected: { model in
                selectedModelId = model.id
                mainStore.dispatch(AppAction.image(.selectImageModelType(model)))
            }),
            isActive: $showModelGridView
        ) {
            EmptyView()
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
                    Text("VIP".localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.text)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            Spacer()
            
            Button {
                showProfile = true
            } label: {
                Image("profiles")
                    .font(.system(size: 44))
                    .foregroundColor(themeManager.accent)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        }
        .frame(height: 44)
    }
}

class MainViewModel: ObservableObject {
    @Published var modelTypes: [ImageModelType]?
    @Published var isSubscribed: Bool = false
    @Published var paymentIsProcessing: Bool = false
    @Published var config: [ImageProcessingEffect]?
    @Published var headerImages: [String]?
    
    init() {
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                (state.imageState, state.paymentState, state.authState)
            }
        }
    }
}

extension MainViewModel: StoreSubscriber {
    func newState(state: (imageState: ImageState, paymentState: PaymentState, authState: AuthState)) {
        DispatchQueue.main.async {
            self.isSubscribed = state.paymentState.isSubscribed
            self.paymentIsProcessing = state.paymentState.isProcessing
            self.config = state.authState.config?.filter {
                $0.region != 0
            }
            self.headerImages = state.authState.config?.filter {
                $0.region == 0
            }.map {
                $0.imageUrl
            }
        }
    }
}
