import SwiftUI
import AVFoundation
import Photos

struct ImageProcessingView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject private var viewModel: ImageProcessingViewModel
    @State private var showCameraView = false
    @State private var beautyEnabled = true
    @State private var showPaymentAlert = false
    @State private var selectedModelType: String?
    
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showPayment: Bool = false
    
    private let buttonSize: CGFloat = 32
    
    init(viewModel: ImageProcessingViewModel = ImageProcessingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // 图片预览区域
            imagePreviewArea
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showPayment.toggle()
                        }, label: {
                            Image(systemName: "crown.fill")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(width: buttonSize, height: buttonSize)
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(themeManager.accent)
                        }
                    }
                }
                .padding(.vertical)
            
            if viewModel.isProcessing {
                ZStack {
                    themeManager.background
                        .opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: themeManager.accent))
                            .scaleEffect(1.5)
                        
                        // 进度条
                        VStack(spacing: 8) {
                            ProgressView(value: viewModel.processProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accent))
                                .frame(width: 200)
                            
                            Text("\(Int(viewModel.processProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(themeManager.text)
                        }
                        
                        Text(viewModel.processMessage)
                            .font(.subheadline)
                            .foregroundColor(themeManager.text)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(themeManager.secondaryBackground)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.isProcessing)
            }
            
            // 底部模型选择区域
//            modelSelectionArea
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
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
                   Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
               }
        .background(themeManager.background)
        .environmentObject(viewModel)
    }
    
    // MARK: - 图片预览区域
    private var imagePreviewArea: some View {
        VStack {
            if let image = viewModel.processedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                HStack(spacing: UIScreen.main.bounds.width / 3) {
                    Button(action: {
                        saveImageToPhotoLibrary()
                    }, label: {
                        VStack {
                            Image("save")
                                .font(.largeTitle)
                                .foregroundColor(themeManager.text)
                            Text("SAVE".localized)
                                .foregroundColor(.black)
                        }
                        
//                        Text("保存")
//                            .foregroundColor(.white) // 设置文字颜色
//                            .font(.headline)
//                            .frame(width: 80, height: 44)
//                            .background(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color(hex: 0x9D40F5), Color(hex: 0xFFB979)]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                            )
//                            .overlay( // 为按钮添加边框
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                            )
                    })

                    Button(action: {
                        viewModel.selectedImage = nil
                        viewModel.processedImage = nil
                        showCameraView = true
                    }, label: {
                        VStack {
                            Image("retake")
                                .font(.largeTitle)
                                .foregroundColor(themeManager.text)
                            Text("RETAKE".localized)
                                .foregroundColor(.black)
                        }
                    })
                }
            } else if  let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                Button(action: {
                    guard let model = viewModel.currentModelType else {
                        return
                    }
                    viewModel.processImage(with: model.id)
                }, label: {
                    Text("PROCESS".localized)
                        .foregroundColor(.white)
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
                })
                
            } else {
                ImageModelTypeSelectionView()
            }
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showCameraView) {
            CustomCameraView(
                selectedImage: $viewModel.selectedImage,
                isPresented: $showCameraView,
                beautyEnabled: $beautyEnabled
            )
        }
    }
    
    // 保存图片到相册
       private func saveImageToPhotoLibrary() {
           guard let image = viewModel.processedImage else {
               alertMessage = "UNKNOWN_ERROR".localized
               showAlert = true
               return
           }
           
           PHPhotoLibrary.requestAuthorization { status in
               switch status {
               case .authorized, .limited:
                   UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                   alertMessage = "SAVE_SUCCESS".localized
                   showAlert = true
               case .denied, .restricted:
                   alertMessage = "NO_PERMISSION".localized
                   showAlert = true
               case .notDetermined:
                   alertMessage = "UNKNOWN_ERROR".localized
                   showAlert = true
               @unknown default:
                   alertMessage = "UNKNOWN_ERROR".localized
                   showAlert = true
               }
           }
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
