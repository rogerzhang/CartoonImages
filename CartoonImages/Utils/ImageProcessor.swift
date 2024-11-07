import UIKit

class ImageProcessor {
    static func processForUpload(_ image: UIImage, maxSizeKB: Int = 100) -> UIImage? {
        // 首先裁剪到合适的尺寸
        let processedImage = cropToSquare(image)
        
        // 然后压缩到目标大小
        return compressImage(processedImage, maxSizeKB: maxSizeKB)
    }
    
    // 裁剪为正方形
    private static func cropToSquare(_ image: UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let minLength = min(originalWidth, originalHeight)
        
        let size = CGSize(width: minLength, height: minLength)
        let x = (originalWidth - minLength) / 2
        let y = (originalHeight - minLength) / 2
        
        let cropRect = CGRect(x: x, y: y, width: minLength, height: minLength)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }
    
    // 压缩图片到指定大小
    private static func compressImage(_ image: UIImage, maxSizeKB: Int) -> UIImage? {
        let maxSize = maxSizeKB * 1024 // 转换为字节
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        
        // 首先尝试调整图片尺寸
        var processedImage = resizeImage(image, maxLength: 800)
        
        guard var imageData = processedImage.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        // 如果调整尺寸后仍然太大，继续压缩质量
        while imageData.count > maxSize && compression > maxCompression {
            compression -= 0.1
            if let data = processedImage.jpegData(compressionQuality: compression) {
                imageData = data
            }
        }
        
        return UIImage(data: imageData)
    }
    
    // 调整图片尺寸
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