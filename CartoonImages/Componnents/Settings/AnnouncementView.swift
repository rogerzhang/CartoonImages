//
//  AnnouncementView.swift
//  CartoonImages
//
//  Created by roger on 2025/3/25.
//

import SwiftUI
import ReSwift

struct AnnouncementView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewModel: AnnouncementViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.list, id: \.id) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            let title = LocalizationManager.shared.currentLanguage == .chinese ? item.title_zh : item.title
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(item.pub_date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        let body = LocalizationManager.shared.currentLanguage == .chinese ? item.body_zh : item.body
                        Text(body)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.markAsRead(announcementId: item.id)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("SETTINGS_ANNOUNCEMENT".localized)
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
        .onAppear {
            viewModel.markAllAsRead()
        }
    }
}

class AnnouncementViewModel: ObservableObject {
    @Published var list: [Announcement] = []
    @Published var isLoading: Bool = false
    private let storageKey = "savedAnnouncements"

    init() {
        loadLocalAnnouncements()
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                state.profileState
            }
        }
    }
    
    func fetchLatestAnnouncement() {
        list.sort { $0.id > $1.id }
        let latestId = list.first?.id ?? 0
        mainStore.dispatch(AppAction.profile(.startFetchAnnounce(version: latestId)))
    }
    
    func loadAnnouncement() {
        list.sort { $0.id > $1.id }
        let latestId = list.first?.id ?? 0
        mainStore.dispatch(AppAction.profile(.startFetchAnnounce(version: latestId)))
    }
    
    func markAsRead(announcementId: Int) {
        if let index = list.firstIndex(where: { $0.id == announcementId }) {
            list[index].isRead = true
            saveAnnouncements()
        }
    }
    
    func markAllAsRead() {
        for index in list.indices {
            list[index].isRead = true
        }
        saveAnnouncements()
        
        resetPushNotificationBadge()
    }
    
    func resetPushNotificationBadge() {
        DispatchQueue.main.async {
            if #available(iOS 17.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    func hasUnread() -> Bool {
        return list.contains { !$0.isRead }
    }
    
    private func loadLocalAnnouncements() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedAnnouncements = try? JSONDecoder().decode([Announcement].self, from: data) {
            list = savedAnnouncements
        }
    }
    
    private func saveAnnouncements() {
        let truncatedList = Array(list.prefix(10)) // Keep only the latest 10
        if let data = try? JSONEncoder().encode(truncatedList) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

extension AnnouncementViewModel: StoreSubscriber {
    func newState(state: ProfileState) {
        DispatchQueue.main.async {
            let newAnnouncements = state.announceList.filter { newAnn in
                !self.list.contains { $0.id == newAnn.id }
            }
            self.list.insert(contentsOf: newAnnouncements, at: 0)
            self.isLoading = state.isLoading
            self.saveAnnouncements()
        }
    }
}
