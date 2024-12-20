import StoreKit

enum PaymentPlanType: String {
    case weekly = "toon.week"
    case monthly = "toon.month"
    case yearly = "toon.year"
    
    var sortOrder: Int {
        switch self {
        case .weekly: return 0
        case .monthly: return 1
        case .yearly: return 2
        }
    }
    
    var type: String {
        switch self {
        case .weekly:
            return "周订阅"
        case .monthly:
            return "月订阅"
        case .yearly:
            return "年订阅"
        }
    }
    
    var per: String {
        switch self {
        case .weekly:
            return "/周"
        case .monthly:
            return "/月"
        case .yearly:
            return "/年"
        }
    }
}

enum PaymentError: Error {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case userCancelled
    case cannotMakePayments
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "未找到商品"
        case .purchaseFailed:
            return "购买失败"
        case .verificationFailed:
            return "验证失败"
        case .userCancelled:
            return "用户取消"
        case .cannotMakePayments:
            return "无法进行支付"
        case .unknown:
            return "未知错误"
        }
    }
}

@MainActor
class PaymentService: NSObject, ObservableObject {
    static let shared = PaymentService()
    
    var products: [SKProduct] = []
    private let paymentQueue = SKPaymentQueue.default()
    private let userDefaults = UserDefaults.standard
    private var transactionDelegate: TransactionDelegate? // 保持强引用
    
    // 用于存储购买状态的 key
    private enum UserDefaultsKeys {
        static let isPremiumUser = "com.app.cartoonimages.isPremiumUser"
        static let purchasedPlan = "com.app.cartoonimages.purchasedPlan"
        static let purchaseDate = "com.app.cartoonimages.purchaseDate"
        static let expirationDate = "com.app.cartoonimages.expirationDate"
    }
    
    // 通知订阅状态变化的回调
    var onSubscriptionStatusChanged: ((Bool) -> Void)?
    
    override init() {
        super.init()
        // 添加交易观察者
        paymentQueue.add(self)
        
        // 启动时检查订阅状态
        Task {
            let isPremium = await isPremiumUser()
            onSubscriptionStatusChanged?(isPremium)
        }
    }
    
    deinit {
        paymentQueue.remove(self)
    }
    
    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // 检查是否是付费用户
    func isPremiumUser() async -> Bool {
        // 首先检查本地存储
        if let isPremium = userDefaults.value(forKey: UserDefaultsKeys.isPremiumUser) as? Bool,
           isPremium {
            // 如果是订阅会员，检查是否过期
            if let expirationDate = userDefaults.value(forKey: UserDefaultsKeys.expirationDate) as? Date {
                if expirationDate > Date() {
                    return true
                }
            }
        }
        
        // 如果本地存储显示不是会员或已过期，验证收据
        return await verifyReceipt()
    }
    
    func localizedPrice(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func expirationDate() -> Date? {
        if let isPremium = userDefaults.value(forKey: UserDefaultsKeys.isPremiumUser) as? Bool,
           isPremium {
            // 如果是订阅会员，检查是否过期
            if let expirationDate = userDefaults.value(forKey: UserDefaultsKeys.expirationDate) as? Date {
                return expirationDate
            }
        }
        return nil
    }
    
    func formartedExpirationDate() -> String {
        if let expirationDate = expirationDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let formattedDate = dateFormatter.string(from: expirationDate)
            
            return formattedDate
        }
        return ""
    }
    
    func expirationDaysFromToday() -> Int {
        if let expirationDate = expirationDate() {
            let currentDate = Date()
            
            let calendar = Calendar.current
            let daysDifference = calendar.dateComponents([.day], from: currentDate, to: expirationDate).day!
            
            return daysDifference
        }
        return -1
    }
    
    // 验证收据
    func verifyReceipt() async -> Bool {
        // 验证应用内购买交易
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try result.payloadValue
                
                // 检查是否是有效的订阅
                if transaction.revocationDate == nil && !transaction.isUpgraded {
                    switch transaction.productType {
                    case .autoRenewable:
                        // 检查订阅是否过期
                        if let expirationDate = transaction.expirationDate,
                           expirationDate > Date() {
                            return true
                        }
                    case .nonConsumable:
                        // 永久购买的情况
                        return true
                    default:
                        break
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        return false
    }
    
    // 更新购买状态
    func updatePurchaseStatus(for planType: PaymentPlanType, transaction: SKPaymentTransaction) {
        // StoreKit 2 方式
        Task {
            for await result in Transaction.currentEntitlements {
                if let transaction = try? result.payloadValue {
                    // 更新过期时间
                    if let expirationDate = transaction.expirationDate {
                        userDefaults.set(expirationDate, forKey: UserDefaultsKeys.expirationDate)
                    }
                    
                    userDefaults.set(true, forKey: UserDefaultsKeys.isPremiumUser)
                    userDefaults.set(planType.rawValue, forKey: UserDefaultsKeys.purchasedPlan)
                    userDefaults.set(Date(), forKey: UserDefaultsKeys.purchaseDate)
                    userDefaults.synchronize()
                    
                    // 通知状态变化
                    onSubscriptionStatusChanged?(true)
                    break
                }
            }
        }
    }
    
    // 清除购买状态（用于测试或重置）
    func clearPurchaseStatus() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.isPremiumUser)
        userDefaults.removeObject(forKey: UserDefaultsKeys.purchasedPlan)
        userDefaults.removeObject(forKey: UserDefaultsKeys.purchaseDate)
        userDefaults.removeObject(forKey: UserDefaultsKeys.expirationDate)
        userDefaults.synchronize()
    }
    
    // 获取当前订阅计划
    func getCurrentPlan() -> PaymentPlanType? {
        guard let planString = userDefaults.string(forKey: UserDefaultsKeys.purchasedPlan) else {
            return nil
        }
        return PaymentPlanType(rawValue: planString)
    }
    
    // 获取订阅过期时间
    func getExpirationDate() -> Date? {
        return userDefaults.value(forKey: UserDefaultsKeys.expirationDate) as? Date
    }
    
    func loadProducts() async throws {
        let productIdentifiers = Set([
            PaymentPlanType.monthly.rawValue,
            PaymentPlanType.yearly.rawValue,
            PaymentPlanType.weekly.rawValue
        ])
        
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        let products = try await withCheckedThrowingContinuation { continuation in
            let productsRequestDelegate = ProductsRequestDelegate { result in
                continuation.resume(with: result)
            }
            request.delegate = productsRequestDelegate
            // 保持 delegate 的引用，防止被过早释放
            objc_setAssociatedObject(request, "delegate", productsRequestDelegate, .OBJC_ASSOCIATION_RETAIN)
            request.start()
        }
        
        self.products = products
    }
    
    func purchase(_ planType: PaymentPlanType) async throws -> SKPaymentTransaction? {
        guard let product = products.first(where: { $0.productIdentifier == planType.rawValue }) else {
            throw PaymentError.productNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let payment = SKPayment(product: product)
            
            // 创建并保持对 delegate 的强引用
            transactionDelegate = TransactionDelegate { result in
                continuation.resume(with: result)
                // 完成后清理 delegate
                self.transactionDelegate = nil
            }
            
            // 添加 delegate 到支付队列
            paymentQueue.add(transactionDelegate!)
            paymentQueue.add(payment)
        }
    }
    
    // 恢复购买
    func restorePurchases() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let restoreDelegate = RestoreTransactionDelegate { result in
                continuation.resume(with: result)
            }
            
            // 保持 delegate 引用
            objc_setAssociatedObject(paymentQueue, "restoreDelegate", restoreDelegate, .OBJC_ASSOCIATION_RETAIN)
            paymentQueue.add(restoreDelegate)
            paymentQueue.restoreCompletedTransactions()
        }
    }
    
    // 处理交易
    private func handleTransaction(_ transaction: SKPaymentTransaction) async {
        guard let planType = PaymentPlanType(rawValue: transaction.payment.productIdentifier) else {
            return
        }
        
        // 更新购买状态
        updatePurchaseStatus(for: planType, transaction: transaction)
        
        // 通知状态变化
        let isPremium = await isPremiumUser()
        onSubscriptionStatusChanged?(isPremium)
        
        // 完成交易
        paymentQueue.finishTransaction(transaction)
    }
}

// 产品请求代理
private class ProductsRequestDelegate: NSObject, SKProductsRequestDelegate {
    private let completion: (Result<[SKProduct], Error>) -> Void
    
    init(completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        self.completion = completion
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        completion(.success(response.products))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completion(.failure(error))
    }
}

// 交易代理
private class TransactionDelegate: NSObject, SKPaymentTransactionObserver {
    private let completion: (Result<SKPaymentTransaction?, Error>) -> Void
    private var hasCompleted = false
    
    init(completion: @escaping (Result<SKPaymentTransaction?, Error>) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            // 确保只调用一次 completion
            guard !hasCompleted else { return }
            
            switch transaction.transactionState {
            case .purchased:
                hasCompleted = true
                completion(.success(transaction))
                queue.finishTransaction(transaction)
                queue.remove(self) // 移除自己作为观察者
                
            case .failed:
                hasCompleted = true
                completion(.failure(transaction.error ?? PaymentError.unknown))
                queue.finishTransaction(transaction)
                queue.remove(self)
                
            case .restored:
                hasCompleted = true
                completion(.success(transaction))
                queue.finishTransaction(transaction)
                queue.remove(self)
                
            case .deferred, .purchasing:
                break
                
            @unknown default:
                break
            }
        }
    }
}

// 添加 SKPaymentTransactionObserver 协议实现
extension PaymentService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        Task {
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased:
                    await handleTransaction(transaction)
                    
                case .restored:
                    await handleTransaction(transaction)
                    
                case .failed:
                    queue.finishTransaction(transaction)
                    
                case .deferred:
                    // 等待外部操作（如家长同意）
                    break
                    
                case .purchasing:
                    // 正在购买中
                    break
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    // 处理订阅续期交易
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        // 自动处理续期交易
        return true
    }
    
    // 处理交易队列恢复完成
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // 通知恢复完成
        Task {
            let isPremium = await isPremiumUser()
            onSubscriptionStatusChanged?(isPremium)
        }
    }
    
    // 处理交易队列恢复失败
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // 处理恢复失败
        print("Restore failed: \(error.localizedDescription)")
    }
}

// 恢复购买的代理
private class RestoreTransactionDelegate: NSObject, SKPaymentTransactionObserver {
    private let completion: (Result<Void, Error>) -> Void
    
    init(completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        completion(.success(()))
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        completion(.failure(error))
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // 处理恢复的交易
    }
}
