import UIKit

class WatermarkManager {
    static func addWatermark(to image: UIImage) -> UIImage {
        let watermarkText = "APP_NAME".localized
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        // 水印文本属性
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 25, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        let textSize = watermarkText.size(withAttributes: attributes)
        
        // 水印位置（右下角）
        let margin: CGFloat = 20
        let rect = CGRect(
            x: image.size.width - textSize.width - margin,
            y: image.size.height - textSize.height - margin,
            width: textSize.width,
            height: textSize.height
        )
        
        // 添加阴影效果
        let context = UIGraphicsGetCurrentContext()
        context?.setShadow(offset: CGSize(width: 1, height: 1), blur: 3, color: UIColor.black.cgColor)
        
        // 绘制水印
        watermarkText.draw(in: rect, withAttributes: attributes)
        
        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return watermarkedImage ?? image
    }
} 
