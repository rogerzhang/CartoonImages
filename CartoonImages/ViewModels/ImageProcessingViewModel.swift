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
    
    func processImage(with modelType: String) {
        print("====[CM]Start: \(Date.now)")
        guard let image = selectedImage, let imageData = ImageProcessor.processForUpload(image) else { return }
        mainStore.dispatch(AppAction.image(.startProcessing(imageData, modelType)))
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
