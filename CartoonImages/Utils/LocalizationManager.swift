import Foundation

enum Language: String {
    case english = "en"
    case chinese = "zh-Hans"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "简体中文"
        }
    }
}

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private let defaults = UserDefaults.standard
    private let languageKey = "AppLanguage"
    
    var currentLanguage: Language {
        get {
            if let savedLanguage = defaults.string(forKey: languageKey),
               let language = Language(rawValue: savedLanguage) {
                return language
            }
            // 如果没有保存的语言设置，使用系统语言
            let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            return Language(rawValue: preferredLanguage) ?? .english
        }
        set {
            defaults.set(newValue.rawValue, forKey: languageKey)
            defaults.synchronize()
            
            // 更新 Bundle
            if let languageBundle = Bundle(path: Bundle.main.path(forResource: newValue.rawValue, ofType: "lproj") ?? "") {
                Bundle.main.setValue(languageBundle, forKey: "localizationBundle")
            }
            
            // 发送通知
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("LanguageChanged")
} 