import SwiftUI

struct ModelGridView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let models: [(id: String, name: String)]
    let onModelSelected: (String) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(models, id: \.id) { model in
                Button(action: { onModelSelected(model.id) }) {
                    VStack {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 30))
                            .foregroundColor(themeManager.accent)
                            .frame(width: 60, height: 60)
                            .background(themeManager.secondaryBackground)
                            .clipShape(Circle())
                        
                        Text(model.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.text)
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