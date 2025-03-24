//
//  ImageModelTypeSelectionView.swift
//  CartoonImages
//
//  Created by roger on 2024/12/10.
//

import SwiftUI
import Kingfisher

struct ImageModelTypeSelectionView: View {
    @State private var currentIndex = mainStore.state.imageState.currentModelType?.id ?? 1
    @State private var beautyEnabled = false
    @State private var showImagePicker = false
    @State private var showPayment = false
    @State var showCameraView: Bool = false
    
    @EnvironmentObject var viewModel: ImageProcessingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            Text("SWIPE_TO_SWITCH")
                .font(.callout)
                .foregroundStyle(themeManager.secondaryText)
            TabView(selection: $currentIndex) {
                ForEach(viewModel.modelTypes) { model in
                    VStack(spacing: 20) {
                        ZStack(alignment: .bottomLeading) {
                            KFImage(URL(string: model.imageUrl))
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(20)
                            
                            HStack {
                                KFImage(URL(string: model.origImgUrl))
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(5)
                                    .shadow(color: .black, radius: 2)
                                    .frame(width: 90, height: 120)
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                let text = LocalizationManager.shared.currentLanguage == .chinese ? model.titleZh : model.title
                                Text(text)
                                    .font(.headline)
                                    .foregroundStyle(themeManager.text)
                                Spacer()
                            }
                            
                            let detailText = LocalizationManager.shared.currentLanguage == .chinese ? model.remarkZh : model.remark
                            Text(detailText)
                                .font(.callout)
                                .foregroundStyle(themeManager.secondaryText)
                        }
                        .padding(.leading, 0)
                    }
                    .tag(model.id)
                }
            }
            .onChange(of: currentIndex) {
                if let model = viewModel.modelTypes.filter({ $0.id == currentIndex }).first {
                    mainStore.dispatch(AppAction.image(.selectImageModelType(model)))
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            ZStack {
                if viewModel.recentImages.isEmpty {
                    cameraButton
                } else {
                    HStack {
                        Spacer()
                        cameraButton
                        recentImagesView
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            processButton
        }
        .fullScreenCover(isPresented: $showCameraView) {
            CustomCameraView(
                selectedImage: $viewModel.selectedImage,
                isPresented: $showCameraView,
                beautyEnabled: $beautyEnabled
            )
        }
        .sheet(isPresented: $showPayment) {
            PaymentView(
                showPaymentAlert: .constant(false),
                paymentIsProcessing: $viewModel.paymentIsProcessing,
                showPaymentError: .constant(false),
                isSubscribed: $viewModel.isSubscribed,
                paymentError: nil,
                handlePayment: {}
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                selectedImage = viewModel.recentImages.first
                viewModel.tempSelectedImage = selectedImage
            }
        }
    }
    
    // MARK: - Recent Images View
    private var recentImagesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.recentImages, id: \.self) { image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(selectedImage == image ? Color.purple : Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 5)
                            .onTapGesture {
                                selectedImage = image
                                viewModel.selectedImage = image
                                viewModel.tempSelectedImage = image
                            }

                        if selectedImage == image {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white))
                                .frame(width: 20, height: 20)
                                .offset(x: 5, y: -5)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .frame(width: min(CGFloat(viewModel.recentImages.count) * 70, UIScreen.main.bounds.width * 0.8))
    }
    
    private var cameraButton: some View {
        Button(action: {
            if viewModel.isSubscribed || (1...3).contains(currentIndex) {
                showCameraView = true
                showPayment = false
            } else {
                showPayment = true
                showCameraView = false
            }
        }) {
            Image(systemName: "camera.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        }
        .padding(.vertical)
    }
    
    private var processButton: some View {
        Button(action: {
            if viewModel.isSubscribed || (1...3).contains(currentIndex) {
                showPayment = false
            } else {
                showPayment = true
                return
            }
            
            viewModel.selectedImage = selectedImage
            
            guard let model = viewModel.currentModelType else {
                return
            }
            viewModel.processImage(with: model)
        }) {
            Text("PROCESS".localized)
                .foregroundColor(.white) // 设置文字颜色
                .font(.headline)
                .frame(width: 200, height: 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: 0x9D40F5), Color(hex: 0xFFB979)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                )
                .overlay( // 为按钮添加边框
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .disabled(selectedImage == nil)
    }
}
