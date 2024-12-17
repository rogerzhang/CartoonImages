import SwiftUI
import Combine
import ReSwift
import Foundation

class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var processProgress: Double = 0
    @Published var processMessage: String = "处理中..."
    @Published var paymentIsProcessing: Bool = false
    @Published var paymentError: String? = nil
    @Published var showPaymentError: Bool = false
    @Published var modelTypes: [ImageModelType] = []
    @Published var currentModelType: ImageModelType?
    
    private var cancellables = Set<AnyCancellable>()
    private var initialModelId: String?
       
    init(initialModelId: String? = nil) {
        self.initialModelId = initialModelId
        
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                (state.imageState, state.paymentState)
            }
        }
    }
    
    func processImage(with modelId: String) {
        guard !isProcessing else { return }
        isProcessing = true
        processProgress = 0
        processMessage = "正在初始化..."
        
        guard let image = selectedImage, let imageData = ImageProcessor.processForUpload(image) else { return }
        mainStore.dispatch(AppAction.image(.startProcessing(imageData, modelId)))

        // 模拟处理过程
        let totalSteps = 5
        var currentStep = 0
        
        func updateProgress() {
            currentStep += 1
            processProgress = Double(currentStep) / Double(totalSteps)
            
            switch currentStep {
            case 1:
                processMessage = "正在加载模型..."
            case 2:
                processMessage = "正在分析图片..."
            case 3:
                processMessage = "正在应用效果..."
            case 4:
                processMessage = "正在优化结果..."
            case 5:
                processMessage = "即将完成..."
            default:
                break
            }
        }
        
        // 模拟处理过程
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            DispatchQueue.main.async {
                if currentStep < totalSteps {
                    updateProgress()
                } else {
                    timer.invalidate()
                    self.processedImage = self.processedImage // 实际应用中这里是处理后的图片
                    self.isProcessing = false
                    self.processProgress = 0
                }
            }
        }
    }
    
    func handlePayment(amount: Decimal) {
        mainStore.dispatch(AppAction.payment(.startPayment(amount: amount)))
    }
    
    func dismissPaymentError() {
        mainStore.dispatch(AppAction.payment(.dismissError))
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
}

extension ImageProcessingViewModel: StoreSubscriber {
    func newState(state: (imageState: ImageState, paymentState: PaymentState)) {
        DispatchQueue.main.async {
            self.selectedImage = state.imageState.selectedImage
            self.processedImage = state.imageState.processedImage
            self.isProcessing = state.imageState.isProcessing
            self.paymentIsProcessing = state.paymentState.isProcessing
            self.paymentError = state.paymentState.error
            self.showPaymentError = state.paymentState.showError
            self.modelTypes = state.imageState.modelTypes ?? []
            self.currentModelType = state.imageState.currentModelType
        }
    }
} 
