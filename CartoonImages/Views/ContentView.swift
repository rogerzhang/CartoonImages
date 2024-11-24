import SwiftUI
import ReSwift
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var cameraPosition: AVCaptureDevice.Position = .front
    @State private var beautyEnabled = true
    
    var body: some View {
        NavigationView {
            MainView()
//                .overlay(
//                    VStack {
//                        HStack {
//                            Button(action: {
//                                sourceType = .camera
//                                showImagePicker = true
//                            }) {
//                                Image(systemName: "camera")
//                                    .font(.title)
//                            }
//                            
//                            Button(action: {
//                                sourceType = .photoLibrary
//                                showImagePicker = true
//                            }) {
//                                Image(systemName: "photo.on.rectangle")
//                                    .font(.title)
//                            }
//                        }
//                        .padding()
//                        
//                        Toggle("美颜", isOn: $beautyEnabled)
//                            .padding()
//                    }
//                )
//                .sheet(isPresented: $showImagePicker) {
//                    ImagePicker(
//                        selectedImage: $viewModel.selectedImage,
//                        sourceType: $sourceType,
//                        cameraPosition: $cameraPosition,
//                        beautyEnabled: $beautyEnabled
//                    )
//                }
        }
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
