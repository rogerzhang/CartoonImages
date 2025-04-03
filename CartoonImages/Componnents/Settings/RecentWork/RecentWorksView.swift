//
//  RecentWorksView.swift
//  CartoonImages
//
//  Created by roger on 2025/3/31.
//

import SwiftUI
import Photos
import AlertToast

struct RecentWorksView: View {
    let images = PortfolioManager.shared.getRecentImages()
    @State private var selectedImageIndex: IdentifiableIndex? = nil
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            selectedImageIndex = IdentifiableIndex(id: index)
                        }
                        .padding(5)
                        .background(themeManager.background)
                        .cornerRadius(12)
                        .shadow(color: themeManager.secondaryBackground, radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("RECENT_WORKS".localized)
        .fullScreenCover(item: $selectedImageIndex) { index in
            ImagePreviewView(images: images, selectedIndex: index.id)
        }
        .background(themeManager.background)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(themeManager.text)
                }
            }
        }
    }
}

struct ImagePreviewView: View {
    let images: [UIImage]
    @State var selectedIndex: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var isSharing = false
    @State private var showSaveAlert = false
    @State private var saveResultMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Button(action: saveToPhotos) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 20))
                                .frame(width: 50, height: 50)
                                .padding()
                                .foregroundColor(.white)
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            isSharing = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .frame(width: 50, height: 50)
                                .padding()
                                .foregroundColor(.white)
                        }
                        .padding(.trailing)
                    }
                    .padding(.bottom)
                }
            )
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .toast(isPresenting: $showSaveAlert, tapToDismiss: false) {
                AlertToast(type: .regular, title: saveResultMessage)
            }
            .sheet(isPresented: $isSharing) {
                let image = images[selectedIndex]
                
                if let data = image.pngData(),
                   let url = saveTemporaryImage(data: data) {
                    ActivityView(activityItems: [url], applicationActivities: nil)
                        .presentationDetents([.height(320)])
                }
            }
        }
    }
    
    func saveTemporaryImage(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("IMAGE".localized)
            .appendingPathExtension("png")
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Error saving temporary image: \(error)")
            return nil
        }
    }

    private func saveToPhotos() {
        let image = images[selectedIndex]
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                DispatchQueue.main.async {
                    saveResultMessage = "SAVE_SUCCESS".localized
                    showSaveAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    saveResultMessage = "NO_PERMISSION".localized
                    showSaveAlert = true
                }
            }
        }
    }
}
