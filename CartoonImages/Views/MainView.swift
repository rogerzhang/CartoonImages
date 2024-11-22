import SwiftUI
import ReSwift

struct MainView: View {
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
    }
}

class MainViewModel: ObservableObject {
    init() {
        // 初始化代码，如果需要的话
    }
}

// 添加一个简单的SettingsView
struct SettingsView: View {
    var body: some View {
        List {
            Button("Logout") {
                mainStore.dispatch(AppAction.auth(.logout))
            }
        }
        .navigationTitle("Settings")
    }
} 
