import SwiftUI
import Kingfisher

struct ModelGridView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let models: [ImageProcessingEffect]
    let onModelSelected: (ImageProcessingEffect) -> Void
    let size: CGSize = CGSize(width: 120, height: 160)
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(models, id: \.id) { model in
                Button(action: {
                    onModelSelected(model)
                }) {
                    ZStack {
                        KFImage(URL(string: model.imageUrl))
                                    .placeholder {
                                        Image("test")
                                            .foregroundColor(themeManager.accent)
                                            .frame(width: size.width, height: size.height)
                                        ProgressView() // 占位图
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: size.width, height: size.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.background)
                    .cornerRadius(12)
                    .shadow(color: themeManager.secondaryBackground, radius: 5)
                }
            }
        }
        .padding()
    }
} 
