import MessageUI
import SwiftUI

class MailHelper {
    static func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    static func getLogContent() -> String {
        return Logger.shared.getLogContent()
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    let toRecipients: [String]
    let subject: String
    let messageBody: String
    let isBodyHTML: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(toRecipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: isBodyHTML)
        
        // 添加日志作为附件
        if let logData = Logger.shared.getLogContent().data(using: .utf8) {
            mailComposer.addAttachmentData(logData, 
                                         mimeType: "text/plain",
                                         fileName: "app.log")
        }
        
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                 didFinishWith result: MFMailComposeResult,
                                 error: Error?) {
            parent.presentation.wrappedValue.dismiss()
        }
    }
} 
