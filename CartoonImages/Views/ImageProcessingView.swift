import SwiftUI
import AVFoundation

struct ImageProcessingView: View {
    @StateObject private var viewModel: ImageProcessingViewModel
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var cameraPosition: AVCaptureDevice.Position = .front
    @State private var beautyEnabled = true
    @State private var showPaymentAlert = false
    
    init(viewModel: ImageProcessingViewModel = ImageProcessingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 图片显示部分
            if let image = viewModel.processedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            
            // 选择图片按钮
//            Button(action: {
//                showImagePicker = true
//            }) {
//                Text(viewModel.selectedImage == nil ? "选择图片" : "重新选择")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .padding(.horizontal)
            
            NavigationLink(destination: {
                CustomCameraView(
                    selectedImage: $viewModel.selectedImage,
                    isPresented: $showImagePicker,
                    beautyEnabled: $beautyEnabled
                ).navigationBarHidden(true)
            }, label: {
                Text(viewModel.selectedImage == nil ? "选择图片" : "重新选择")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            
            // 处理图片按钮
            if viewModel.selectedImage != nil {
                Button(action: {
                    viewModel.processImage()
                }) {
                    HStack {
                        if viewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: "wand.and.stars")
                                .padding(.trailing, 5)
                        }
                        Text(viewModel.isProcessing ? "处理中..." : "开始处理")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isProcessing)
                .padding(.horizontal)
                
                NavigationLink(destination: {
                    // 支付入口区域
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
                }, label: {
                    Text("Purchase")
                        .foregroundStyle(.white)
                        .font(.title)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10))
                })
                
                
            }
            
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            CustomCameraView(
                selectedImage: $viewModel.selectedImage,
                isPresented: $showImagePicker,
                beautyEnabled: $beautyEnabled
            )
        }
    }
} 
