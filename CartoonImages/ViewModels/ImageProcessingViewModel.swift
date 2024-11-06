class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func processImage() {
        guard let image = selectedImage else { return }
        isProcessing = true
        error = nil
        
        NetworkService.shared.processImage(image)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    if case let .failure(error) = completion {
                        self?.error = error.displayDescription
                        mainStore.dispatch(AppAction.image(.processFailure(error)))
                    }
                },
                receiveValue: { [weak self] processedImage in
                    self?.processedImage = processedImage
                    mainStore.dispatch(AppAction.image(.processSuccess(processedImage)))
                }
            )
            .store(in: &cancellables)
    }
} 