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
                
                // 支付入口区域
                VStack(spacing: 12) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    // 会员服务说明
                    VStack(alignment: .leading, spacing: 8) {
                        Text("会员服务")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("无限次数处理图片")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("高级滤镜效果")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("批量处理功能")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // 价格和支付按钮
                    VStack(spacing: 10) {
                        Text("¥1.99/月")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            showPaymentAlert = true
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("立即开通")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.paymentIsProcessing)
                    }
                    .padding(.horizontal)
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
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
        .alert("确认支付", isPresented: $showPaymentAlert) {
            Button("确认") {
                if let amount = Decimal(string: "1.99") {
                    viewModel.handlePayment(amount: amount)
                }
                showPaymentAlert = false
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("开通会员服务 ¥1.99/月")
        }
        .alert("支付错误", isPresented: Binding(
            get: { viewModel.showPaymentError },
            set: { _ in viewModel.dismissPaymentError() }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.paymentError ?? "未知错误")
        }
    }
} 
