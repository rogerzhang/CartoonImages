import UIKit

extension UIImage {
    func size() -> Int {
        guard let imageData = self.jpegData(compressionQuality: 1) else {
            return 0
        }
        
        let size = imageData.count
        return size
    }
}

class ImageProcessor {
    static func processForUpload(_ image: UIImage, maxSizeKB: Int = 100) -> UIImage? {
        print("====start: \(Date.now)")
        let processedImage = cropToSquare(image)
        let res = compressImage(processedImage, maxSizeKB: maxSizeKB)
        print("====end: \(Date.now)")
        return res
    }
    
    private static func cropToSquare(_ image: UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let minLength = min(originalWidth, originalHeight)
        
        let x = (originalWidth - minLength) / 2
        let y = (originalHeight - minLength) / 2
        
        let cropRect = CGRect(x: x, y: y, width: minLength, height: minLength)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }
    
    private static func compressImage(_ image: UIImage, maxSizeKB: Int) -> UIImage? {
        let maxSize = maxSizeKB * 1024
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        
        let processedImage = resizeImage(image, maxLength: 800)
        
        guard var imageData = processedImage.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        while imageData.count > maxSize && compression > maxCompression {
            compression -= 0.1
            if let data = processedImage.jpegData(compressionQuality: compression) {
                imageData = data
            }
        }
        
        return UIImage(data: imageData)
    }
    
    private static func resizeImage(_ image: UIImage, maxLength: CGFloat) -> UIImage {
        let originalSize = image.size
        var newSize = originalSize
        
        if originalSize.width > maxLength || originalSize.height > maxLength {
            let ratio = originalSize.width / originalSize.height
            if ratio > 1 {
                newSize = CGSize(width: maxLength, height: maxLength / ratio)
            } else {
                newSize = CGSize(width: maxLength * ratio, height: maxLength)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
} 
