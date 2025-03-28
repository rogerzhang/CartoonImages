import SwiftUI
import AVFoundation
import Photos
import AlertToast
import Lottie

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
    @State private var showShareSheet: Bool = false
    
    private let buttonSize: CGFloat = 32
    
    init(viewModel: ImageProcessingViewModel = ImageProcessingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // 图片预览区域
            imagePreviewArea
                .toolbar {
                    if viewModel.processedImage == nil {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showPayment.toggle()
                            }, label: {
                                Image(systemName: "crown.fill")
                                    .font(.callout)
                                    .foregroundColor(.yellow)
                                    .frame(width: buttonSize, height: buttonSize)
                            })
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showShareSheet.toggle()
                            }, label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.callout)
                                    .foregroundColor(themeManager.accent)
                                    .frame(width: buttonSize, height: buttonSize)
                            })
                        }
                    }
              
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            viewModel.selectedImage = nil
                            viewModel.processedImage = nil
                            mainStore.dispatch(AppAction.image(.selectImage(nil)))
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
                        VStack {
                            SafeLottieView(name: "loading3", loopMode: .loop, animationSpeed: 1.0)
                                .frame(width: 100, height: 100)
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        
                        Text(viewModel.processMessage + "\(Int(viewModel.processProgress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(themeManager.text)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.isProcessing)
            }
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
        .sheet(isPresented: $showShareSheet) {
            if let image = viewModel.processedImage,
               let data = image.pngData(),
               let url = saveTemporaryImage(data: data) {
                ActivityView(activityItems: [url], applicationActivities: nil)
                    .presentationDetents([.height(320)])
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(isPresenting: $showAlert, tapToDismiss: false) {
            AlertToast(type: .regular, title: alertMessage)
        }
        .alert(isPresented: $viewModel.showProcessError) {
            Alert(title: Text("ERROR_OCCURRED".localized), message: Text(viewModel.processErrorMsg ?? "TRY_IT_LATER".localized), dismissButton: .default(Text("OK".localized)))
        }
        .background(themeManager.background)
        .environmentObject(viewModel)
        .onDisappear {
            viewModel.selectedImage = nil
            viewModel.processedImage = nil
            mainStore.dispatch(AppAction.image(.selectImage(nil)))
        }
        .onAppear {
            DispatchQueue.main.async {
                viewModel.loadRecentImages()
            }
        }
    }
    
    func saveTemporaryImage(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("IMAGE".localized)
            .appendingPathExtension("png")
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Error saving temporary image: \(error)")
            return nil
        }
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
            }
            else if  viewModel.isProcessing {
                let image = viewModel.selectedImage ?? viewModel.tempSelectedImage
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
//                Button(action: {
//                    guard let model = viewModel.currentModelType else {
//                        return
//                    }
//                    viewModel.processImage(with: model)
//                }, label: {
//                    Text("PROCESS".localized)
//                        .foregroundColor(.white)
//                        .font(.headline)
//                        .frame(width: 200, height: 60)
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color(hex: 0x9D40F5), Color(hex: 0xFFB979)]),
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                        )
//                        .overlay( // 为按钮添加边框
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                })
                
            }
            else {
                VStack {
                    ImageModelTypeSelectionView()
                }
            
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
    
    // Save the processed image and update recent images
    private func saveImageToPhotoLibrary() {
        guard let image = viewModel.processedImage else {
            alertMessage = "UNKNOWN_ERROR".localized
            showAlert = true
            return
        }
        
        // Save to photo library
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
} 
