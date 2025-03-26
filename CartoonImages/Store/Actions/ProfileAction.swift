//
//  ProfileAction.swift
//  CartoonImages
//
//  Created by roger on 2025/3/25.
//

import Foundation

enum ProfileAction {
    case startFetchAnnounce(version: Int)
    case fetchAnnounceSuccess([Announcement])
    case fetchAnnounceFailed(Error)
    case makeAllAnnounceRead
}
