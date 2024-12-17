import SwiftUI
import AVFoundation
import Photos

struct CustomCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var viewModel: ImageProcessingViewModel
    @StateObject private var camera = CameraController()
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @Binding var beautyEnabled: Bool
    @State private var showPhotoLibrary = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeManager.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(themeManager.foreground)
                                .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: { camera.switchCamera() }) {
                            Image(systemName: "camera.rotate")
                                .font(.title2)
                                .foregroundColor(themeManager.foreground)
                                .padding()
                        }
                    }
                    .frame(height: 44)
                    .background(themeManager.background.opacity(0.8))
                    
                    GeometryReader { geometry in
                        ZStack {
                            CameraPreviewView(session: camera.session)
                                .frame(width: geometry.size.width - 20,
                                      height: geometry.size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                .padding(.horizontal, 10)
                        }
                        .background(themeManager.background)
                    }
                    .frame(maxHeight: .infinity)
                    
                    HStack {
                        Button(action: { showPhotoLibrary = true }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(themeManager.foreground)
                                .frame(width: 60, height: 60)
                        }
                        
                        Spacer()
                        
                        Button(action: { camera.capturePhoto() }) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.accent)
                                    .frame(width: 70, height: 70)
                                Circle()
                                    .stroke(themeManager.accent, lineWidth: 3)
                                    .frame(width: 80, height: 80)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { beautyEnabled.toggle() }) {
                            Image(systemName: beautyEnabled ? "sparkles" : "wand.and.stars.inverse")
                                .font(.title2)
                                .foregroundColor(beautyEnabled ? .yellow : themeManager.foreground)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding(.horizontal, 30)
                    .frame(height: 100)
                    .background(themeManager.background.opacity(0.8))
                }
                
                if camera.showConfirmation {
                    PhotoConfirmationView(
                        selectedImage: .constant(camera.tempImage),
                        onRetake: {
                            camera.showConfirmation = false
                            camera.tempImage = nil
                            camera.restartSession()
                        },
                        onConfirm: {
                            selectedImage = camera.tempImage
                            dismiss()
                            guard let model = viewModel.currentModelType else {
                                return
                            }
                            viewModel.processImage(with: model.id)
                        }
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: camera.showConfirmation)
                }
            }
        }
        .fullScreenCover(isPresented: $showPhotoLibrary) {
            ImagePickerView(
                selectedImage: $selectedImage,
                isPresented: $showPhotoLibrary,
                beautyEnabled: $beautyEnabled
            )
        }
        .onAppear {
            camera.checkPermissions()
            camera.setBindings(
                selectedImage: $selectedImage,
                isPresented: $isPresented,
                beautyEnabled: $beautyEnabled
            )
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.frame = uiView.bounds
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
        
        if let connection = videoPreviewLayer.connection {
            connection.automaticallyAdjustsVideoMirroring = false
            let isFrontCamera = (videoPreviewLayer.session?.inputs.first as? AVCaptureDeviceInput)?.device.position == .front
            connection.isVideoMirrored = isFrontCamera
        }
    }
}

class CameraController: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var position: AVCaptureDevice.Position = .front
    private var videoInput: AVCaptureDeviceInput?
    private var beautyFilter: CIFilter?
    private let context = CIContext()
    
    private var displayLayer: AVSampleBufferDisplayLayer?
    
    private var videoDataOutput: AVCaptureVideoDataOutput?
    
    private var selectedImage: Binding<UIImage?>?
    private var isPresented: Binding<Bool>?
    private var beautyEnabled: Binding<Bool>?
    
    @Published var showConfirmation = false
    @Published var tempImage: UIImage?
    
    override init() {
        super.init()
        setupBeautyFilter()
    }
    
    private func setupBeautyFilter() {
        beautyFilter = CIFilter(name: "CIHighlightShadowAdjust")
        beautyFilter?.setValue(1.4, forKey: "inputHighlightAmount")
        beautyFilter?.setValue(0.3, forKey: "inputShadowAmount")
    }
    
    private func cleanUpSession() {
        sessionQueue.sync {
            if session.isRunning {
                session.stopRunning()
            }
            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            session.commitConfiguration()
        }
    }
    
    private let sessionQueue = DispatchQueue(label: "com.app.camera.sessionQueue")

    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            
            if session.isRunning {
                session.stopRunning()
            }
            
            self.session.beginConfiguration()
            
            // 清除旧的输入和输出
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                            for: .video,
                                                            position: self.position) else {
                self.session.commitConfiguration()
                return
            }
            
            do {
                // 添加输入
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    self.videoInput = videoInput
                }
                
                // 添加照片输出
                if self.session.canAddOutput(self.photoOutput) {
                    
                    self.session.addOutput(self.photoOutput)
                    
                    if let connection = self.photoOutput.connection(with: .video) {
                        connection.videoOrientation = .portrait
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = (self.position == .front)
                    }
                }
                
                // 添加视频数据输出
                let videoDataOutput = AVCaptureVideoDataOutput()
                videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                
                if self.session.canAddOutput(videoDataOutput) {
                    self.session.addOutput(videoDataOutput)
                    self.videoDataOutput = videoDataOutput
                    
                    if let connection = videoDataOutput.connection(with: .video) {
                        connection.videoOrientation = .portrait
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = (self.position == .front)
                    }
                }
                
                // 配置完成，提交更改
                self.session.sessionPreset = .photo
                self.session.commitConfiguration()
                
                // 启动会话
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            } catch {
                print("Error setting up camera: \(error.localizedDescription)")
                self.session.commitConfiguration()
            }
        }
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    func switchCamera() {
        position = position == .front ? .back : .front
        session.stopRunning()
        session.inputs.forEach { session.removeInput($0) }
        setupCamera()
    }
    
    func capturePhoto() {
        guard let photoOutput = session.outputs.first as? AVCapturePhotoOutput else {
            print("Photo output not found")
            return
        }
        
        let settings = AVCapturePhotoSettings()
//        settings.flashMode = .auto
        
        DispatchQueue.main.async {
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
    
    func openPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    
                    if let keyWindow = self.getKeyWindow(),
                       let rootViewController = keyWindow.rootViewController {
                        var topController = rootViewController
                        while let presentedController = topController.presentedViewController {
                            topController = presentedController
                        }
                        
                        topController.present(picker, animated: true)
                    }
                    
                case .denied, .restricted:
                    let alert = UIAlertController(
                        title: "需要相册访问权限",
                        message: "请在设置中允许访问相册",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                    alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    })
                    
                    if let keyWindow = self.getKeyWindow(),
                       let rootViewController = keyWindow.rootViewController {
                        rootViewController.present(alert, animated: true)
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    private func presentImagePicker() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isPresented?.wrappedValue = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(picker, animated: true)
                }
            }
        }
    }
    
    func stopSession() {
        session.stopRunning()
        session.inputs.forEach { session.removeInput($0) }
    }
    
    func setBindings(selectedImage: Binding<UIImage?>,
                    isPresented: Binding<Bool>,
                    beautyEnabled: Binding<Bool>) {
        self.selectedImage = selectedImage
        self.isPresented = isPresented
        self.beautyEnabled = beautyEnabled
    }
    
    private func applyBeautyFilter(to image: UIImage, completion: @escaping (UIImage) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(image)
            return
        }
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        var currentImage = ciImage
        
        if let smoothFilter = CIFilter(name: "CIBilateralFilter") {
            smoothFilter.setValue(currentImage, forKey: kCIInputImageKey)
            smoothFilter.setValue(10.0, forKey: "inputSpatialRadius")
            smoothFilter.setValue(0.8, forKey: "inputDistanceMultiplier")
            if let output = smoothFilter.outputImage {
                currentImage = output
            }
        }
        
        if let whiteningFilter = CIFilter(name: "CIColorControls") {
            whiteningFilter.setValue(currentImage, forKey: kCIInputImageKey)
            whiteningFilter.setValue(0.1, forKey: kCIInputBrightnessKey)
            whiteningFilter.setValue(1.1, forKey: kCIInputSaturationKey)
            whiteningFilter.setValue(1.05, forKey: kCIInputContrastKey)
            if let output = whiteningFilter.outputImage {
                currentImage = output
            }
        }
        
        if let skinFilter = CIFilter(name: "CIColorMatrix") {
            skinFilter.setValue(currentImage, forKey: kCIInputImageKey)
            skinFilter.setValue(CIVector(x: 1.1, y: 0, z: 0, w: 0), forKey: "inputRVector")
            skinFilter.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
            skinFilter.setValue(CIVector(x: 0, y: 0, z: 1.0, w: 0), forKey: "inputBVector")
            if let output = skinFilter.outputImage {
                currentImage = output
            }
        }
        
        if let outputImage = context.createCGImage(currentImage, from: currentImage.extent, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()) {
            let finalImage = UIImage(cgImage: outputImage)
            completion(finalImage)
        } else {
            completion(image)
        }
    }
    
    func restartSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        session.stopRunning()
        
        guard let imageData = photo.fileDataRepresentation(),
              var image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 先修正图片方向
            image = image.fixOrientation()
            
            // 存储临时图片并显示确认视图
            if let beautyEnabled = self.beautyEnabled, beautyEnabled.wrappedValue {
                // 应用美颜效果
                self.applyBeautyFilter(to: image) { processedImage in
                    self.tempImage = processedImage
                    self.showConfirmation = true
                }
            } else {
                self.tempImage = image
                self.showConfirmation = true
            }
        }
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let beautyEnabled = beautyEnabled?.wrappedValue,
              beautyEnabled else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        var currentImage = ciImage
        
        if let smoothFilter = CIFilter(name: "CIBilateralFilter") {
            smoothFilter.setValue(currentImage, forKey: kCIInputImageKey)
            smoothFilter.setValue(10.0, forKey: "inputSpatialRadius")
            smoothFilter.setValue(0.8, forKey: "inputDistanceMultiplier")
            if let output = smoothFilter.outputImage {
                currentImage = output
            }
        }
        
        if let whiteningFilter = CIFilter(name: "CIColorControls") {
            whiteningFilter.setValue(currentImage, forKey: kCIInputImageKey)
            whiteningFilter.setValue(0.1, forKey: kCIInputBrightnessKey)
            whiteningFilter.setValue(1.1, forKey: kCIInputSaturationKey)
            whiteningFilter.setValue(1.05, forKey: kCIInputContrastKey)
            if let output = whiteningFilter.outputImage {
                currentImage = output
            }
        }
        
        if let skinFilter = CIFilter(name: "CIColorMatrix") {
            skinFilter.setValue(currentImage, forKey: kCIInputImageKey)
            skinFilter.setValue(CIVector(x: 1.1, y: 0, z: 0, w: 0), forKey: "inputRVector")
            skinFilter.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
            skinFilter.setValue(CIVector(x: 0, y: 0, z: 1.0, w: 0), forKey: "inputBVector")
            if let output = skinFilter.outputImage {
                currentImage = output
            }
        }
        
        context.render(currentImage,
                      to: pixelBuffer,
                      bounds: currentImage.extent,
                      colorSpace: CGColorSpaceCreateDeviceRGB())
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
} 

extension UIImage {
    func withHorizontallyFlippedOrientation() -> UIImage {
        if let cgImage = self.cgImage {
            let flippedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .upMirrored)
            
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            flippedImage.draw(in: CGRect(origin: .zero, size: size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return normalizedImage ?? self
        }
        return self
    }
    
    func normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
} 

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
} 

extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if let beautyEnabled = beautyEnabled?.wrappedValue, beautyEnabled {
                applyBeautyFilter(to: image) { processedImage in
                    self.selectedImage?.wrappedValue = processedImage
                }
            } else {
                self.selectedImage?.wrappedValue = image
            }
        }
        
        picker.dismiss(animated: true) {
            self.isPresented?.wrappedValue = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @Binding var beautyEnabled: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        
        // 添加关闭按钮
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: context.coordinator, action: #selector(context.coordinator.cancel))
        picker.navigationItem.leftBarButtonItem = cancelButton
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if parent.beautyEnabled {
                    applyBeautyFilter(to: image) { processedImage in
                        self.parent.selectedImage = processedImage
                        self.parent.isPresented = false
                    }
                } else {
                    parent.selectedImage = image
                    parent.isPresented = false
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
        
        private func applyBeautyFilter(to image: UIImage, completion: @escaping (UIImage) -> Void) {
            guard let ciImage = CIImage(image: image) else {
                completion(image)
                return
            }
            
            let context = CIContext(options: [.useSoftwareRenderer: false])
            var currentImage = ciImage
            
            if let smoothFilter = CIFilter(name: "CIBilateralFilter") {
                smoothFilter.setValue(currentImage, forKey: kCIInputImageKey)
                smoothFilter.setValue(10.0, forKey: "inputSpatialRadius")
                smoothFilter.setValue(0.8, forKey: "inputDistanceMultiplier")
                if let output = smoothFilter.outputImage {
                    currentImage = output
                }
            }
            
            if let whiteningFilter = CIFilter(name: "CIColorControls") {
                whiteningFilter.setValue(currentImage, forKey: kCIInputImageKey)
                whiteningFilter.setValue(0.1, forKey: kCIInputBrightnessKey)
                whiteningFilter.setValue(1.1, forKey: kCIInputSaturationKey)
                whiteningFilter.setValue(1.05, forKey: kCIInputContrastKey)
                if let output = whiteningFilter.outputImage {
                    currentImage = output
                }
            }
            
            if let skinFilter = CIFilter(name: "CIColorMatrix") {
                skinFilter.setValue(currentImage, forKey: kCIInputImageKey)
                skinFilter.setValue(CIVector(x: 1.1, y: 0, z: 0, w: 0), forKey: "inputRVector")
                skinFilter.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
                skinFilter.setValue(CIVector(x: 0, y: 0, z: 1.0, w: 0), forKey: "inputBVector")
                if let output = skinFilter.outputImage {
                    currentImage = output
                }
            }
            
            if let outputImage = context.createCGImage(currentImage, from: currentImage.extent) {
                completion(UIImage(cgImage: outputImage))
            } else {
                completion(image)
            }
        }
        
        @objc func cancel() {
            parent.isPresented = false
        }
    }
}
