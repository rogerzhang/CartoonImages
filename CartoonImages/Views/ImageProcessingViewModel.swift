import SwiftUI
import ReSwift

class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var paymentIsProcessing = false
    @Published var showPaymentError = false
    @Published var paymentError: String?
    
    let modelTypes = [
        (id: "1", name: "动漫风格"),
        (id: "2", name: "素描风格"),
        (id: "3", name: "油画风格"),
        (id: "4", name: "水彩风格"),
        (id: "5", name: "铅笔画"),
        (id: "6", name: "复古风格")
    ]
    
    private var initialModelId: String?
    
    init(initialModelId: String? = nil) {
        self.initialModelId = initialModelId
        
        // 如果提供了初始模型ID，自动开始处理
        if let modelId = initialModelId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processImage(with: modelId)
            }
        }
    }
    
    func processImage(with modelId: String) {
        guard !isProcessing else { return }
        isProcessing = true
        
        // 模拟图片处理过程
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 2.0) // 模拟处理时间
            
            DispatchQueue.main.async {
                self.processedImage = self.selectedImage // 这里应该是实际的处理结果
                self.isProcessing = false
            }
        }
    }
    
    func handlePayment(_ amount: Decimal) {
        paymentIsProcessing = true
        
        // 模拟支付过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.paymentIsProcessing = false
            // 模拟支付失败
            self.showPaymentError = true
            self.paymentError = "支付失败，请稍后重试"
        }
    }
    
    func dismissPaymentError() {
        showPaymentError = false
        paymentError = nil
    }
} 