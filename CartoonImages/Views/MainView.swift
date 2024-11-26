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
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
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
