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
    
    // 示例数据
    private let carouselImages = ["banner1", "banner2", "banner3"]
    private let modelTypes = [
        (id: "1", name: "动漫风格"),
        (id: "2", name: "素描风格"),
        (id: "3", name: "油画风格"),
        (id: "4", name: "水彩风格"),
        (id: "5", name: "铅笔画"),
        (id: "6", name: "复古风格")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                topNavigationBar
                    .padding(.horizontal)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    .background(themeManager.background)
                
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
                            
                            ModelGridView(models: modelTypes) { modelId in
                                selectedModelId = modelId
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
            .background(themeManager.background.ignoresSafeArea())
            .edgesIgnoringSafeArea(.top)
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
            
            Spacer()
            
            NavigationLink(destination: {
                ProfileView()
            }, label: {
                Image("profiles")
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.accent)
            })
        }
    }
}

class MainViewModel: ObservableObject {
    init() {
        // 初始化代码，如果需要的话
    }
}

#Preview(body: {
    MainView()
})
