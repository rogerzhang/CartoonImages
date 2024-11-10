import SwiftUI

struct ImageProcessingView: View {
    @StateObject private var viewModel = ImageProcessingViewModel()
    @State private var showImagePicker = false
    @State private var showPaymentAlert = false
    
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
                
                // 显示图片大小
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    Text("Image size: \(String(format: "%.1f", Double(imageData.count) / 1024.0)) KB")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            
            // 选择图片按钮
            Button(action: {
                showImagePicker = true
            }) {
                Text(viewModel.selectedImage == nil ? "选择图片" : "重新选择")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
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
            }
            
            // Apple Pay 按钮
            if viewModel.processedImage != nil {
                Button(action: {
                    showPaymentAlert = true
                }) {
                    HStack {
                        if viewModel.paymentIsProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "applelogo")
                        Text("使用 Apple Pay 支付")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.paymentIsProcessing)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: Binding(
                get: { viewModel.selectedImage },
                set: { viewModel.selectedImage = $0 }
            ))
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
            Text("需要支付 ¥1.99 以保存处理后的图片")
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
