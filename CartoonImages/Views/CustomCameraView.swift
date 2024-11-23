import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @StateObject private var camera = CameraController()
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @Binding var beautyEnabled: Bool
    let backgroundColor: Color = .white.opacity(1)
    let foregroundColor: Color = Color(uiColor: .darkGray)
    let cameraButtonColor: Color = .purple
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(foregroundColor)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: { camera.switchCamera() }) {
                        Image(systemName: "camera.rotate")
                            .font(.title2)
                            .foregroundColor(foregroundColor)
                            .padding()
                    }
                }
                .frame(height: 60)
                .background(backgroundColor)
                
                GeometryReader { geometry in
                    ZStack {
                        CameraPreviewView(session: camera.session)
                            .frame(width: geometry.size.width - 20,
                                  height: geometry.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                            .padding(.horizontal, 10)
                    }
                }
                .frame(maxHeight: .infinity)
                
                HStack {
                    Button(action: { camera.openPhotoLibrary() }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(foregroundColor)
                            .frame(width: 60, height: 60)
                    }
                    
                    Spacer()
                    
                    Button(action: { camera.capturePhoto() }) {
                        ZStack {
                            Circle()
                                .fill(cameraButtonColor)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(cameraButtonColor, lineWidth: 3)
                                .frame(width: 80, height: 80)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { beautyEnabled.toggle() }) {
                        Image(systemName: beautyEnabled ? "sparkles" : "wand.and.stars.inverse")
                            .font(.title2)
                            .foregroundColor(beautyEnabled ? .yellow : foregroundColor)
                            .frame(width: 60, height: 60)
                    }
                }
                .padding(.horizontal, 30)
                .frame(height: 100)
                .background(backgroundColor)
            }
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
            connection.isVideoMirrored = (videoPreviewLayer.session?.inputs.first as? AVCaptureDeviceInput)?.device.position == .front
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
    
    override init() {
        super.init()
        setupBeautyFilter()
    }
    
    private func setupBeautyFilter() {
        beautyFilter = CIFilter(name: "CIHighlightShadowAdjust")
        beautyFilter?.setValue(1.4, forKey: "inputHighlightAmount")
        beautyFilter?.setValue(0.3, forKey: "inputShadowAmount")
    }
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: .video,
                                                          position: self.position) else {
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    self.videoInput = videoInput
                }
                
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                let videoDataOutput = AVCaptureVideoDataOutput()
                videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                
                if self.session.canAddOutput(videoDataOutput) {
                    self.session.addOutput(videoDataOutput)
                    self.videoDataOutput = videoDataOutput
                    
                    if let connection = videoDataOutput.connection(with: .video) {
                        connection.videoOrientation = .portrait
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = (self.position == .front)
                    }
                }
                
                if let connection = self.photoOutput.connection(with: .video) {
                    connection.videoOrientation = .portrait
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = false
                }
                
                self.session.sessionPreset = .high
                self.session.commitConfiguration()
                
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            } catch {
                print("Error setting up camera: \(error.localizedDescription)")
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
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func openPhotoLibrary() {
        isPresented?.wrappedValue = false
    }
    
    func stopSession() {
        session.stopRunning()
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
        
        // 1. 磨皮
        if let smoothFilter = CIFilter(name: "CIBilateralFilter") {
            smoothFilter.setValue(currentImage, forKey: kCIInputImageKey)
            smoothFilter.setValue(10.0, forKey: "inputSpatialRadius")
            smoothFilter.setValue(0.8, forKey: "inputDistanceMultiplier")
            if let output = smoothFilter.outputImage {
                currentImage = output
            }
        }
        
        // 2. 美白和调色
        if let whiteningFilter = CIFilter(name: "CIColorControls") {
            whiteningFilter.setValue(currentImage, forKey: kCIInputImageKey)
            whiteningFilter.setValue(0.1, forKey: kCIInputBrightnessKey)    // 降低亮度避免过曝
            whiteningFilter.setValue(1.1, forKey: kCIInputSaturationKey)    // 适度提高饱和度
            whiteningFilter.setValue(1.05, forKey: kCIInputContrastKey)     // 轻微提高对比度
            if let output = whiteningFilter.outputImage {
                currentImage = output
            }
        }
        
        // 3. 肤色优化
        if let skinFilter = CIFilter(name: "CIColorMatrix") {
            skinFilter.setValue(currentImage, forKey: kCIInputImageKey)
            skinFilter.setValue(CIVector(x: 1.1, y: 0, z: 0, w: 0), forKey: "inputRVector")  // 轻微增强红色
            skinFilter.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector") // 轻微增强绿色
            skinFilter.setValue(CIVector(x: 0, y: 0, z: 1.0, w: 0), forKey: "inputBVector")
            if let output = skinFilter.outputImage {
                currentImage = output
            }
        }
        
        // 确保输出图像在正确的颜色空间中
        if let outputImage = context.createCGImage(currentImage, from: currentImage.extent, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()) {
            let finalImage = UIImage(cgImage: outputImage)
            completion(finalImage)
        } else {
            completion(image)
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              var image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 1. 修正图片方向
            image = image.fixOrientation()
            
            // 2. 应用美颜效果或直接使用原图
            if let beautyEnabled = self.beautyEnabled, beautyEnabled.wrappedValue {
                self.applyBeautyFilter(to: image) { processedImage in
                    // 3. 如果是前置摄像头，在美颜处理后进行水平翻转
                    if self.position == .front {
                        if let cgImage = processedImage.cgImage {
                            let finalImage = UIImage(cgImage: cgImage, scale: processedImage.scale, orientation: .upMirrored)
                            self.selectedImage?.wrappedValue = finalImage
                        } else {
                            self.selectedImage?.wrappedValue = processedImage
                        }
                    } else {
                        self.selectedImage?.wrappedValue = processedImage
                    }
                    self.isPresented?.wrappedValue = false
                }
            } else {
                // 不使用美颜时的处理逻辑保持不变
                if self.position == .front {
                    if let cgImage = image.cgImage {
                        image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
                    }
                }
                self.selectedImage?.wrappedValue = image
                self.isPresented?.wrappedValue = false
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
        
        // 检查是否启用美颜
        guard let beautyEnabled = beautyEnabled?.wrappedValue,
              beautyEnabled else {
            // 美颜关闭时，直接返回，让原始预览显示
            return
        }
        
        // 以下是美颜处理的代码
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        var currentImage = ciImage
        
        // 1. 磨皮效果
        if let smoothFilter = CIFilter(name: "CIBilateralFilter") {
            smoothFilter.setValue(currentImage, forKey: kCIInputImageKey)
            smoothFilter.setValue(10.0, forKey: "inputSpatialRadius")
            smoothFilter.setValue(0.8, forKey: "inputDistanceMultiplier")
            if let output = smoothFilter.outputImage {
                currentImage = output
            }
        }
        
        // 2. 美白和调色
        if let whiteningFilter = CIFilter(name: "CIColorControls") {
            whiteningFilter.setValue(currentImage, forKey: kCIInputImageKey)
            whiteningFilter.setValue(0.1, forKey: kCIInputBrightnessKey)
            whiteningFilter.setValue(1.1, forKey: kCIInputSaturationKey)
            whiteningFilter.setValue(1.05, forKey: kCIInputContrastKey)
            if let output = whiteningFilter.outputImage {
                currentImage = output
            }
        }
        
        // 3. 肤色优化
        if let skinFilter = CIFilter(name: "CIColorMatrix") {
            skinFilter.setValue(currentImage, forKey: kCIInputImageKey)
            skinFilter.setValue(CIVector(x: 1.1, y: 0, z: 0, w: 0), forKey: "inputRVector")
            skinFilter.setValue(CIVector(x: 0, y: 1.05, z: 0, w: 0), forKey: "inputGVector")
            skinFilter.setValue(CIVector(x: 0, y: 0, z: 1.0, w: 0), forKey: "inputBVector")
            if let output = skinFilter.outputImage {
                currentImage = output
            }
        }
        
        // 渲染处理后的图像到原始 pixelBuffer
        context.render(currentImage,
                      to: pixelBuffer,
                      bounds: currentImage.extent,
                      colorSpace: CGColorSpaceCreateDeviceRGB())
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
} 

// 添加 UIImage 扩展来处理镜像
extension UIImage {
    func withHorizontallyFlippedOrientation() -> UIImage {
        if let cgImage = self.cgImage {
            // 确保图片方向正确后再进行水平翻转
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

// 添加 UIImage 扩展来修正方向
extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi/2)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let cgImage = self.cgImage,
              let colorSpace = cgImage.colorSpace,
              let ctx = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return self
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        guard let newCGImage = ctx.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: newCGImage, scale: scale, orientation: .up)
    }
} 
