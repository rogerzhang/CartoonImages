import UIKit
import Foundation

enum ImageAction {
    case selectImage(UIImage?)
    case startProcessing(UIImage, String)
    case processSuccess(UIImage)
    case processFailure(Error)
    case updateProcessingStatus(Bool)
} 
