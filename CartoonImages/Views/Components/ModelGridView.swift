import SwiftUI
import Kingfisher

struct ModelGridView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let models: [ImageProcessingEffect]
    let title: String
    let onModelSelected: (ImageProcessingEffect) -> Void
    let size: CGSize = CGSize(width: 160, height: 160 * 4 / 3)
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
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
                                .scaledToFill()
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            // 让文本在左下角
                            VStack {
                                Spacer() // 占据上方空间，Text 会贴到底部
                                HStack {
                                    Text(LocalizationManager.shared.currentLanguage == .chinese ? model.titleZh : model.title)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(6)  // 内边距
                                        .background(Color.black.opacity(0.1)) // 半透明背景
                                        .cornerRadius(5) // 圆角
                                    Spacer() // 占据右侧空间，使 Text 靠左
                                }
                                .frame(maxWidth: .infinity) // 让 HStack 撑满
                                .padding(.leading, 10) // 左侧间距
                                .padding(.bottom, 10)  // 底部间距
                            }
                            .frame(width: size.width, height: size.height) // 让 VStack 充满整个 ZStack
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(themeManager.background)
                        .cornerRadius(12)
                        .shadow(color: themeManager.secondaryBackground, radius: 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(themeManager.accent)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
} 
