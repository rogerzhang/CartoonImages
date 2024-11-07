class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var error: String?
    @Published var showError = false
    @Published var showTips = false
    @Published var selectedModelType = "1"
    
    let modelTypes: [(id: String, name: String)] = [
        ("1", "Style 1"),
        ("2", "Style 2"),
        ("3", "Style 3"),
        ("4", "Style 4")
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    // 监听 selectedImage 的变化
    init() {
        $selectedImage
            .sink { [weak self] image in
                if let image = image {
                    // 打印处理后的图片大小
                    if let imageData = image.jpegData(compressionQuality: 1.0) {
                        print("Image size: \(Double(imageData.count) / 1024.0) KB")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
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
                        self?.error = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] processedImage in
                    self?.processedImage = processedImage
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        self.error = error.localizedDescription
        self.showError = true
        self.showTips = error.localizedDescription.contains("face")
    }
} 