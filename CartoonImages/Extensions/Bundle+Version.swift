import Foundation

extension Bundle {
    static func version() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        #if DEBUG
        return "\(version)(\(build))"
        #else
        return version
        #endif
    }
    
    static func appName() -> String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String 
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String 
            ?? "APP_NAME".localized
    }
} 
