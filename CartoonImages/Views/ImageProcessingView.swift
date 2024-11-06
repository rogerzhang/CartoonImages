import SwiftUI
import ReSwift

struct ImageProcessingView: View {
    @StateObject private var viewModel = ImageProcessingViewModel()
    @State private var showImagePicker = false
    
    var body: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Button("Process Image") {
                    viewModel.processImage()
                }
                .disabled(viewModel.isProcessing)
            } else {
                Button("Select Image") {
                    showImagePicker = true
                }
            }
            
            if viewModel.isProcessing {
                ProgressView()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error ?? "Unknown error")
        }
    }
}

class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var error: String?
    @Published var showError = false
    
    init() {
        mainStore.subscribe(self)
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
    
    func processImage() {
        guard let image = selectedImage else { return }
        mainStore.dispatch(AppAction.image(.startProcessing))
    }
}

extension ImageProcessingViewModel: StoreSubscriber {
    func newState(state: AppState) {
        DispatchQueue.main.async {
            self.isProcessing = state.imageState.isProcessing
            if let error = state.imageState.error {
                self.error = error.localizedDescription
                self.showError = true
            }
            if let processedImage = state.imageState.processedImage {
                self.processedImage = processedImage
            }
        }
    }
} 
