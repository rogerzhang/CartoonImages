//
//  ProfileReducer.swift
//  CartoonImages
//
//  Created by roger on 2025/3/25.
//

import Foundation

func profileReducer(action: ProfileAction, state: ProfileState) -> ProfileState {
    var newState = state
    
    switch action {
    case .startFetchAnnounce:
        newState.isLoading = true
    case .fetchAnnounceSuccess(let list):
        newState.announceList = list
        newState.hasNew = list.count > 0
    case .makeAllAnnounceRead:
        newState.hasNew = false
    default:
        break
    }
    
    return newState
}
