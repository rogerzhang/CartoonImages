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
    @Published var colorScheme: ColorScheme = .light
    
    // 背景色
    var background: Color {
        colorScheme == .dark ? Color.black : Color.white
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
        Color.gray
    }
    
    // 更新颜色模式
    func updateColorScheme(_ scheme: ColorScheme) {
//        colorScheme = scheme
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
