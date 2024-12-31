import SwiftUI

struct ModelGridView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let models: [ImageModelType]
    let onModelSelected: (ImageModelType) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(models, id: \.id) { model in
                let imageName = UIImage(named: model.id) == nil ? "test" : model.id
                Button(action: { onModelSelected(model) }) {
                    ZStack {
                        Image(imageName)
                            .foregroundColor(themeManager.accent)
                            .frame(width: 120, height: 160)
                        
//                        HStack {
//                            Text(model.name)
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(themeManager.text)
//                        }
//                        .background(Color.clear)
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
