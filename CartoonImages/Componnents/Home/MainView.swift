import SwiftUI
import ReSwift

struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showProfile = false
    @State private var showPayment = false
    @StateObject private var announcementViewModel = AnnouncementViewModel()
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
        NavigationStack {
            ZStack(alignment: .top) {
                themeManager.background
                    .ignoresSafeArea()
                
                ZStack(alignment: .top) {
                    // 固定在顶部的导航栏
                    topNavigationBar
                        .padding(.horizontal)
                        .zIndex(1)
                    
                    // 滚动内容
                    ScrollView {
                        VStack(spacing: 20) {
                            if let images = viewModel.headerImages, images.count > 0 {
                                CarouselView(images: images)
                                    .frame(height: 240)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 0)
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
                    .edgesIgnoringSafeArea(.top)
    //                .safeAreaInset(edge: .top, content: {
    //                    Color.clear.frame(height: 0) // 让内容填充安全区
    //                })
                }
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
                    .environmentObject(announcementViewModel)
            }
            .background(navigationLinkToModelGridView())
            .onAppear {
                if NetworkPermissionManager.shared.isNetworkAuthorized {
                    announcementViewModel.fetchLatestAnnouncement()
                }
            }
            .onReceive(NetworkPermissionManager.shared.$isNetworkAuthorized) { isAuthorized in
                if isAuthorized {
                    announcementViewModel.fetchLatestAnnouncement()
                }
            }
    //        .onChange(of: scenePhase) { newPhase in
    //            if newPhase == .active, NetworkPermissionManager.shared.isNetworkAuthorized {
    //                announcementViewModel.fetchLatestAnnouncement()
    //            }
    //        }
        }
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
                        .opacity(0.8)
                    Text("VIP".localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            Spacer()
            
            Button {
                showProfile = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image("profiles")
                        .font(.system(size: 44))
                        .foregroundColor(themeManager.accent)
                    if announcementViewModel.hasUnread() {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
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
