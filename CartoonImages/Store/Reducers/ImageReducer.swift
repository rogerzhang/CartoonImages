import ReSwift

func imageReducer(action: ImageAction, state: ImageState) -> ImageState {
    var newState = state
    
    switch action {
    case let .selectImageModelType(modelType):
        newState.currentModelType = modelType
    case let .selectImage(image):
        newState.selectedImage = image
        newState.processedImage = nil
        newState.error = nil
        newState.showError = false
        
    case .startProcessing:
        newState.error = nil
        newState.processedImage = nil
        
    case let .processSuccess(image):
        newState.processedImage = image
        newState.error = nil
        newState.showError = false
        PortfolioManager.shared.saveImage(image)
        
    case let .processFailure(error):
        newState.error = error.localizedDescription
        newState.showError = true
        newState.showTips = error.localizedDescription.contains("face")
        
    case let .updateProcessingStatus(isProcessing):
        newState.isProcessing = isProcessing
    }
    
    return newState
}
