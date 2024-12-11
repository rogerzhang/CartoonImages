import SwiftUI
import AVFoundation

struct ImageProcessingView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel: ImageProcessingViewModel
    @State private var showImagePicker = false
    @State private var beautyEnabled = true
    @State private var showPaymentAlert = false
    @State private var selectedModelType: String?
    
    private let buttonSize: CGFloat = 32
    
    init(viewModel: ImageProcessingViewModel = ImageProcessingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 图片预览区域
            imagePreviewArea
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: {
                            PaymentView(
                                showPaymentAlert: $showPaymentAlert,
                                paymentIsProcessing: $viewModel.paymentIsProcessing,
                                showPaymentError: Binding(
                                    get: { viewModel.showPaymentError },
                                    set: { _ in viewModel.dismissPaymentError() }
                                ),
                                paymentError: viewModel.paymentError,
                                handlePayment: viewModel.handlePayment
                            )
                        }) {
                            Image(systemName: "crown.fill")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(width: buttonSize, height: buttonSize)
                        }
                    }
                }
                .padding(.vertical)
            
            // 底部模型选择区域
//            modelSelectionArea
        }
        .background(themeManager.background)
        .environmentObject(viewModel)
    }
    
    // MARK: - 顶部导航栏
    private var topNavigationBar: some View {
        HStack {
            // 会员支付按钮
            NavigationLink(destination: {
                PaymentView(
                    showPaymentAlert: $showPaymentAlert,
                    paymentIsProcessing: $viewModel.paymentIsProcessing,
                    showPaymentError: Binding(
                        get: { viewModel.showPaymentError },
                        set: { _ in viewModel.dismissPaymentError() }
                    ),
                    paymentError: viewModel.paymentError,
                    handlePayment: viewModel.handlePayment
                )
            }) {
                Image(systemName: "diamond.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(Circle().fill(Color.blue.opacity(0.2)))
            }
            
            Spacer()
            
            // 用户信息按钮
            Button(action: {
                // 处理用户信息按钮点击
            }) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
        }
        .padding()
    }
    
    // MARK: - 图片预览区域
    private var imagePreviewArea: some View {
        VStack {
            if let image = viewModel.processedImage ?? viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                ImageModelTypeSelectionView()
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 底部模型选择区域
//    private var modelSelectionArea: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            LazyHStack(spacing: 15) {
//                ForEach(viewModel.modelTypes, id: \.id) { modelType in
//                    modelTypeButton(for: modelType)
//                }
//            }
//            .padding()
//        }
//        .frame(height: 100)
//        .background(Color.gray.opacity(0.1))
//    }
    
    private func modelTypeButton(for modelType: (id: String, name: String)) -> some View {
        Button(action: {
            guard viewModel.selectedImage != nil else { return }
            selectedModelType = modelType.id
            viewModel.processImage(with: modelType.id)
        }) {
            VStack {
                Text(modelType.name)
                    .foregroundColor(selectedModelType == modelType.id ? 
                        themeManager.text : 
                        themeManager.secondaryText)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedModelType == modelType.id ? 
                                themeManager.accent : 
                                themeManager.secondaryBackground)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.accent, lineWidth: 1)
                    )
                
                if viewModel.isProcessing && selectedModelType == modelType.id {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.accent))
                        .scaleEffect(0.7)
                }
            }
        }
        .disabled(viewModel.isProcessing || viewModel.selectedImage == nil)
    }
} 
