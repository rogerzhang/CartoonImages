import PassKit
import Combine

class PaymentService {
    static let shared = PaymentService()
    private let merchantIdentifier = "merchant.com.yourapp.id" // 替换为你的商户ID
    
    private init() {}
    
    // 检查是否可以使用 Apple Pay
    func canMakePayments() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments() &&
               PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }
    
    // 支持的支付网络
    private var supportedNetworks: [PKPaymentNetwork] {
        var networks: [PKPaymentNetwork] = [
            .masterCard,
            .visa
        ]
        if #available(iOS 14.5, *) {
            networks.append(.chinaUnionPay)
        }
        return networks
    }
    
    // 创建支付请求
    func createPaymentRequest(amount: Decimal) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.supportedNetworks = supportedNetworks
        request.merchantCapabilities = .capability3DS
        request.countryCode = "CN"
        request.currencyCode = "CNY"
        
        // 创建支付项目，将 Decimal 转换为 NSDecimalNumber
        let item = PKPaymentSummaryItem(
            label: "图片处理服务",
            amount: NSDecimalNumber(decimal: amount)
        )
        
        request.paymentSummaryItems = [item]
        return request
    }
    
    // 处理支付
    func processPayment(amount: Decimal) -> AnyPublisher<String, Error> {
        return Future { promise in
            let request = self.createPaymentRequest(amount: amount)
            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            let delegate = PaymentControllerDelegate { result in
                switch result {
                case .success(let transactionId):
                    promise(.success(transactionId))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
            
            controller.delegate = delegate
            controller.present { presented in
                if !presented {
                    promise(.failure(PaymentError.presentationFailed))
                }
            }
            
            // 保持 delegate 的引用
            PaymentControllerDelegate.shared = delegate
        }.eraseToAnyPublisher()
    }
}

// 支付错误类型
enum PaymentError: LocalizedError {
    case notAvailable
    case presentationFailed
    case cancelled
    case failed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Pay 不可用"
        case .presentationFailed:
            return "无法显示支付界面"
        case .cancelled:
            return "支付已取消"
        case .failed(let message):
            return "支付失败: \(message)"
        }
    }
}

// 支付控制器代理
private class PaymentControllerDelegate: NSObject, PKPaymentAuthorizationControllerDelegate {
    static var shared: PaymentControllerDelegate?
    private let completion: (Result<String, Error>) -> Void
    
    init(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // 这里应该调用你的后端 API 处理支付
        // 示例中我们模拟成功
        let transactionId = UUID().uuidString
        self.completion(.success(transactionId))
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            PaymentControllerDelegate.shared = nil
        }
    }
} 