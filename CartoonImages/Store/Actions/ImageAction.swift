import UIKit
import Foundation

enum ImageAction {
    case selectImageModelType(ImageProcessingEffect)
    case selectImage(UIImage?)
    case startProcessing(Data, ImageProcessingEffect)
    case processSuccess(UIImage)
    case processFailure(Error)
    case updateProcessingStatus(Bool)
} 
