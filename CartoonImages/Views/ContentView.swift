import SwiftUI
import ReSwift
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = ContentViewModel()
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var cameraPosition: AVCaptureDevice.Position = .front
    @State private var beautyEnabled = true
    
    var body: some View {
        NavigationView {
            MainView()
                .background(themeManager.background)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        }
        .accentColor(themeManager.accent)
    }
}

class ContentViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var selectedImage: UIImage?
    
    init() {
        mainStore.subscribe(self) { subscription in
            subscription.select { state in state.authState.isLoggedIn }
        }
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
}

extension ContentViewModel: StoreSubscriber {
    func newState(state: Bool) {
        isLoggedIn = state
    }
} 
