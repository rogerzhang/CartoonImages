import SwiftUI
import UIKit
import Combine

struct ImageProcessingView: View {
    @StateObject private var viewModel = ImageProcessingViewModel()
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = viewModel.processedImage {
                // 显示处理后的图片
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else if let image = viewModel.selectedImage {
                // 显示选择的原图
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
                // 显示占位图
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            
            if viewModel.showTips {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tips for best results:")
                        .font(.headline)
                    Text("• Choose a photo with a clear, front-facing face")
                    Text("• Ensure good lighting")
                    Text("• Avoid photos with multiple faces")
                    Text("• Avoid photos with face partially covered")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            // 模型选择器
            if viewModel.selectedImage != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Style:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Style", selection: $viewModel.selectedModelType) {
                        ForEach(viewModel.modelTypes, id: \.id) { model in
                            Text(model.name).tag(model.id)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select Image")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
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
                            Text(viewModel.isProcessing ? "Processing..." : "Transform Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.isProcessing)
                }
            }
            .padding(.horizontal)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage)
        }
        .alert("Cannot Process Image", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showTips = viewModel.error?.contains("face") == true
            }
        } message: {
            Text(viewModel.error ?? "Unknown error")
        }
    }
}

class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var error: String?
    @Published var showError = false
    @Published var showTips = false
    @Published var selectedModelType = "1"  // 默认使用模型 1
    
    // 可用的模型类型及其显示名称
    let modelTypes: [(id: String, name: String)] = [
        ("0", "Style 0"),
        ("1", "Style 1"),
        ("2", "Style 2"),
        ("3", "Style 3"),
        ("4", "Style 4")
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    func processImage() {
        guard let image = selectedImage else { return }
        
        isProcessing = true
        error = nil
        processedImage = nil
        
        NetworkService.shared.processImage(image, modelType: selectedModelType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    if case let .failure(error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] processedImage in
                    self?.processedImage = processedImage
                    mainStore.dispatch(AppAction.image(.processSuccess(processedImage)))
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: ProcessImageError) {
        self.error = error.userMessage
        self.showError = true
        
        // 对于特定错误显示提示
        if case .noFaceDetected = error {
            self.showTips = true
        }
        
        mainStore.dispatch(AppAction.image(.processFailure(error)))
    }
    
    // 清理函数
    func cleanup() {
        selectedImage = nil
        processedImage = nil
        error = nil
        isProcessing = false
    }
}

// 预览
struct ImageProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageProcessingView()
    }
} 
