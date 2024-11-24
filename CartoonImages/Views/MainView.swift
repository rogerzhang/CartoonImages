import SwiftUI
import ReSwift

struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        TabView {
            ImageProcessingView()
                .tabItem {
                    Image(systemName: "photo.fill")
                    Text("处理图片")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(themeManager.accent)
    }
}

class MainViewModel: ObservableObject {
    init() {
        // 初始化代码，如果需要的话
    }
}

// 添加一个简单的SettingsView
struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        List {
            Button("Logout") {
                mainStore.dispatch(AppAction.auth(.logout))
            }
            .foregroundColor(themeManager.text)
        }
        .background(themeManager.background)
        .navigationTitle("Settings")
    }
} 
