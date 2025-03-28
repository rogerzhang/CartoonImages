import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    @EnvironmentObject private var themeManager: ThemeManager
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // 设置UI颜色
        controller.view.backgroundColor = UIColor(themeManager.background)
        
        // 设置弹出样式
        if let popover = controller.popoverPresentationController {
            popover.permittedArrowDirections = .any
            popover.backgroundColor = UIColor(themeManager.background)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 更新UI颜色
        uiViewController.view.backgroundColor = UIColor(themeManager.background)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
