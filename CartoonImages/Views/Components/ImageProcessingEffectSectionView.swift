//
//  ImageProcessingEffectSectionView.swift
//  CartoonImages
//
//  Created by roger on 2025/3/18.
//

import SwiftUI
import Kingfisher

struct ImageProcessingEffectSectionView: View {
    let item: (region: Int, region_title: String, region_title_zh: String, effects: [ImageProcessingEffect])
    @EnvironmentObject private var themeManager: ThemeManager
    let size: CGSize = CGSize(width: 120, height: 160)
    
    let onModelSelected: (ImageProcessingEffect) -> Void
    let onMoreBtnSelected: ([ImageProcessingEffect]) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                let text = LocalizationManager.shared.currentLanguage == .chinese ? item.region_title_zh : item.region_title
                Text(text)
                    .font(.headline)
                    .foregroundColor(themeManager.text)
                    .padding(.vertical, 0)
                
                Spacer()
                
                if item.effects.count > 6 {
                    Button(action: {
                        onMoreBtnSelected(item.effects)
                    }) {
                        Text("MORE".localized)
                            .font(.headline)
                            .foregroundColor(themeManager.text)
                            .padding(.vertical, 0)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(item.effects.prefix(6), id: \.id) { effect in
                        Button(action: {
                            onModelSelected(effect)
                        }) {
                            KFImage(URL(string: effect.imageUrl))
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
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
