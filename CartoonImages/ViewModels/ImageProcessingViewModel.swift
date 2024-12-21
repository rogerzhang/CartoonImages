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
    @Published var isSubscribed: Bool = false
    
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
        processMessage = "PROCESSING_INIT".localized
        
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
                processMessage = "PROCESSING_MODEL".localized
            case 2:
                processMessage = "PROCESSING_ANALYZE".localized
            case 3:
                processMessage = "PROCESSING_EFFECT".localized
            case 4:
                processMessage = "PROCESSING_OPTIMIZE".localized
            case 5:
                processMessage = "PROCESSING_COMPLETE".localized
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
    //func handlePayment(amount: Decimal) {
    func handlePayment() {
        guard let currentPlan = self.currentModelType else {
            return
        }
        
        var type: PaymentPlanType = .monthly
        
        if currentPlan.id == "1" {
            type = .weekly
        } else if currentPlan.id == "3" {
            type = .yearly
        }
        
        mainStore.dispatch(AppAction.payment(.startPayment(type)))
    }
    
    func dismissPaymentError() {
//        mainStore.dispatch(AppAction.payment(.dismissError))
    }
    
    func handlePurchase(planType: PaymentPlanType) {
        Task {
            do {
                mainStore.dispatch(PaymentAction.startPayment(planType))
                
                // 加载商品
                try await PaymentService.shared.loadProducts()
                
                // 执行购买
                if (try await PaymentService.shared.purchase(planType)) != nil {
                    // 购买成功
                    await MainActor.run {
                        mainStore.dispatch(PaymentAction.paymentSuccess)
                    }
                }
            } catch {
                await MainActor.run {
                    mainStore.dispatch(PaymentAction.paymentFailure(error))
                }
            }
        }
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
//            self.showPaymentError = state.paymentState.showError
            self.modelTypes = state.imageState.modelTypes ?? []
            self.currentModelType = state.imageState.currentModelType
            self.isSubscribed = state.paymentState.isSubscribed
        }
    }
} 
