import SwiftUI
import Combine
import ReSwift
import Foundation

class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing: Bool = false
    @Published var paymentIsProcessing: Bool = false
    @Published var paymentError: String? = nil
    @Published var showPaymentError: Bool = false
    
    let modelTypes: [(id: String, name: String)] = [
        ("1", "Style 1"),
        ("2", "Style 2"),
        ("3", "Style 3"),
        ("4", "Style 4")
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 订阅 Store 的状态变化
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                (state.imageState, state.paymentState)
            }
        }
    }
    
    func processImage(with modelType: String) {
        guard let image = selectedImage else { return }
        mainStore.dispatch(AppAction.image(.startProcessing(image, modelType)))
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
        }
    }
} 
