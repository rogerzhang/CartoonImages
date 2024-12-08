import SwiftUI

struct CarouselView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let images: [String] // 图片名称数组
    @State private var currentIndex = 0
    
    // 自动滚动的定时器
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 图片轮播
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 指示器
            HStack(spacing: 8) {
                ForEach(0..<images.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? themeManager.accent : themeManager.secondaryText)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 8)
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
} 