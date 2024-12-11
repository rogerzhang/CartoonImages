import UIKit
import Foundation

enum ImageAction {
    case selectImageModelType(ImageModelType)
    case selectImage(UIImage?)
    case startProcessing(Data, String)
    case processSuccess(UIImage)
    case processFailure(Error)
    case updateProcessingStatus(Bool)
} 
