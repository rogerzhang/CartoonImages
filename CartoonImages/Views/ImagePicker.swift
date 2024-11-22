import SwiftUI
import UIKit
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var beautyEnabled: Bool
    @Binding var cameraPosition: AVCaptureDevice.Position
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
        
        if sourceType == .camera {
            picker.cameraDevice = cameraPosition == .front ? .front : .rear
            
            let overlayView = UIView(frame: picker.view.bounds)
            overlayView.backgroundColor = .clear
            
            let closeButton = UIButton(frame: CGRect(x: 20, y: 40, width: 44, height: 44))
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.tintColor = .black
            closeButton.addTarget(context.coordinator, 
                                action: #selector(Coordinator.dismissPicker),
                                for: .touchUpInside)
            
            let switchButton = UIButton(frame: CGRect(x: picker.view.bounds.width - 64, y: 40, width: 44, height: 44))
            switchButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
            switchButton.tintColor = .black
            switchButton.addTarget(context.coordinator, 
                                 action: #selector(Coordinator.switchCamera),
                                 for: .touchUpInside)
            
            let albumButton = UIButton(frame: CGRect(x: 20, y: picker.view.bounds.height - 100, width: 44, height: 44))
            albumButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
            albumButton.tintColor = .black
            albumButton.addTarget(context.coordinator, 
                                action: #selector(Coordinator.openPhotoLibrary),
                                for: .touchUpInside)
            
            let beautyButton = UIButton(frame: CGRect(x: picker.view.bounds.width - 64, y: picker.view.bounds.height - 100, width: 44, height: 44))
            beautyButton.setImage(UIImage(systemName: beautyEnabled ? "sparkles" : "sparkles.slash"), for: .normal)
            beautyButton.tintColor = beautyEnabled ? .systemYellow : .black
            beautyButton.addTarget(context.coordinator, 
                                 action: #selector(Coordinator.toggleBeauty),
                                 for: .touchUpInside)
            
            overlayView.addSubview(closeButton)
            overlayView.addSubview(switchButton)
            overlayView.addSubview(albumButton)
            overlayView.addSubview(beautyButton)
            
            picker.view.backgroundColor = .white
            picker.cameraOverlayView = overlayView
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        if sourceType == .camera {
            uiViewController.cameraDevice = cameraPosition == .front ? .front : .rear
        }
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
