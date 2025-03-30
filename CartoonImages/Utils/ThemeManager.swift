import SwiftUI

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: opacity)
    }
}

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme = .dark
    
    // 背景色
    var background: Color {
        colorScheme == .dark ? Color(hex: 0x101929) : Color.white
    }
    
    // 前景色
    var foreground: Color {
        colorScheme == .dark ? Color.white : Color(uiColor: .darkGray)
    }
    
    // 强调色（固定值）
    let accent: Color = .purple
    
    // 次要背景色
    var secondaryBackground: Color {
        colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)
    }
    
    // 主文本色
    var text: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    // 次要文本色
    var secondaryText: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    var cardBackground: Color {
        colorScheme == .dark ? Color(hex: 0x1E1E1E) : Color.white
    }
    
    var cardAccent: Color {
        colorScheme == .dark ? Color(hex: 0x333333) : Color.black
    }
    
    var benefitsBackground: Color {
        colorScheme == .dark ? Color(hex: 0x2A2A2A) : Color(hex: 0xF8FFEC)
    }
    
    var benefitsBorder: Color {
        colorScheme == .dark ? Color(hex: 0x4A4A4A) : Color(hex: 0x6CEACF)
    }
    
    var buttonBackground: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    var buttonText: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    var loadingBackground: Color {
        colorScheme == .dark ? Color(hex: 0x333333) : Color(hex: 0x222222)
    }
    
    var planBackground: Color {
        colorScheme == .dark ? Color(hex: 0x2C2C2E) : Color.white
    }
        
    var selectedPlanBackground: Color {
        colorScheme == .dark ? Color(hex: 0x3A3A3C) : Color(hex: 0xF8FFEC)
    }
        
    var planBorder: Color {
        colorScheme == .dark ? Color(hex: 0x444446) : Color.gray.opacity(0.5)
        
    }
        
    var selectedPlanBorder: Color {
        colorScheme == .dark ? Color(hex: 0x6CEACF) : Color(hex: 0x6CEACF)
        
    }
        
    var planText: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
        
    var selectedPlanText: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
        
    var planSecondaryText: Color {
        colorScheme == .dark ? Color.gray : Color.gray
    }
        
    var selectedPlanSecondaryText: Color {
        colorScheme == .dark ? Color(hex: 0x6CEACF) : Color(hex: 0x6CEACF)
    }
        
    var selectedPlanShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.3)
    }
    
    // 更新颜色模式
    func updateColorScheme(_ scheme: ColorScheme) {
        colorScheme = scheme
    }
    
    // 监听系统颜色模式变化
    func startObservingColorScheme() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleColorSchemeChange),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // 停止监听
    func stopObservingColorScheme() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // 处理颜色模式变化
    @objc private func handleColorSchemeChange() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let newColorScheme = windowScene.traitCollection.userInterfaceStyle == .dark ? ColorScheme.dark : ColorScheme.light
            if newColorScheme != colorScheme {
                DispatchQueue.main.async {
                    self.updateColorScheme(newColorScheme)
                }
            }
        }
    }
    
    // 初始化时开始监听
    init() {
        startObservingColorScheme()
    }
    
    // 析构时停止监听
    deinit {
        stopObservingColorScheme()
    }
} 
