import SwiftUI

struct PhotoConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Binding var selectedImage: UIImage?
    
    let onRetake: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Button(action: onRetake) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(themeManager.foreground)
                        .padding()
                }
                
                Spacer()
                
                Button(action: onConfirm) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(themeManager.foreground)
                        .padding()
                }
            }
            .frame(height: 44)
            .background(themeManager.background)
            
            // 图片预览区域
            GeometryReader { geometry in
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width - 20,
                                  height: geometry.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .padding(.horizontal, 10)
                    }
                }
                .background(themeManager.background)
            }
            .frame(maxHeight: .infinity)
            
            // 底部工具栏
            HStack {
                Button(action: onRetake) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                        Text("重拍")
                            .font(.caption)
                    }
                    .foregroundColor(themeManager.foreground)
                    .frame(width: 60, height: 60)
                }
                
                Spacer()
                
                Button(action: onConfirm) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("使用")
                            .font(.caption)
                    }
                    .foregroundColor(.purple)  // 使用与拍照按钮相同的颜色
                    .frame(width: 60, height: 60)
                }
            }
            .padding(.horizontal, 30)
            .frame(height: 100)
            .background(themeManager.background)
        }
        .background(themeManager.background)
    }
} 
