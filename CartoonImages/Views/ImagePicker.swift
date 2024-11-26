import SwiftUI
import UIKit
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selectedImage: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var cameraPosition: AVCaptureDevice.Position
    @Binding var beautyEnabled: Bool
    @Environment(\.presentationMode) var presentationMode
    
    init(selectedImage: Binding<UIImage?>,
         sourceType: Binding<UIImagePickerController.SourceType>,
         cameraPosition: Binding<AVCaptureDevice.Position>,
         beautyEnabled: Binding<Bool>) {
        self._selectedImage = selectedImage
        self._sourceType = sourceType
        self._cameraPosition = cameraPosition
        self._beautyEnabled = beautyEnabled
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        
        // 设置导航栏颜色
        picker.navigationBar.barTintColor = UIColor(themeManager.background)
        picker.navigationBar.tintColor = UIColor(themeManager.accent)
        picker.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(themeManager.text)
        ]
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 更新UI颜色
        uiViewController.view.backgroundColor = UIColor(themeManager.background)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, 
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if parent.beautyEnabled {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let processedImage = self.applyBeautyFilter(to: image)
                        DispatchQueue.main.async {
                            self.parent.selectedImage = processedImage
                            self.parent.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    parent.selectedImage = image
                    parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        @objc func switchCamera() {
            parent.cameraPosition = parent.cameraPosition == .front ? .back : .front
        }
        
        private func applyBeautyFilter(to image: UIImage) -> UIImage {
            guard let ciImage = CIImage(image: image) else { return image }
            
            let filter = CIFilter(name: "CIFaceSmoothness")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(0.8, forKey: "inputIntensity")
            
            guard let outputImage = filter?.outputImage,
                  let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
                return image
            }
            
            return UIImage(cgImage: cgImage)
        }
        
        @objc func dismissPicker() {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        @objc func openPhotoLibrary() {
            parent.sourceType = .photoLibrary
        }
        
        @objc func toggleBeauty() {
            parent.beautyEnabled.toggle()
        }
    }
}
