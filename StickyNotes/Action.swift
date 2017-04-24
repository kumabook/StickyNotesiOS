//
//  Action.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import ReactiveSwift
import Delta
import APIKit

struct LoginAction: Delta.ActionType {
    typealias StateValueType = AppState
    let email: String
    let password: String
    
    func reduce(state: AppState) -> AppState {
        let request = AccessTokenRequest(email: email, password: password)
        Session.send(request) { result in
            switch result {
            case .success(let accessToken):
                APIClient.sharedInstance.accessToken = accessToken
                Store.sharedInstance.dispatch(LoggedInAction(accessToken: accessToken))
                Store.sharedInstance.dispatch(FetchStickiesAction())
            case .failure(let error):
                print("error: \(error)")
            }
        }
        return state
    }
}

struct LoggedInAction: Delta.ActionType {
    typealias StateValueType = AppState
    let accessToken: AccessToken
    func reduce(state: AppState) -> AppState {
        state.accessToken.value = accessToken
        return state
    }
}

struct LogoutAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        APIClient.sharedInstance.accessToken = nil
        APIClient.sharedInstance.lastSyncedAt = Date(timeIntervalSince1970: 0)
        StickyRepository.sharedInstance.clear()
        state.accessToken.value = nil
        return state
    }
}

struct FetchStickiesAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        state.stickiesRepository.updateStickies() {isSuccess in
            if !isSuccess {
                return
            }
            state.stickiesRepository.fetchStickies() { isSuccess in
                if isSuccess {
                    Store.sharedInstance.dispatch(FetchedStickiesAction())
                }
            }
        }
        return state
    }
}

struct FetchedStickiesAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        return state
    }
}

struct DeleteStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        let _ = StickyRepository.sharedInstance.removeSticky(sticky)
        return state
    }
}

struct EditStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    let editSticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.listingSticky(page: sticky.page!)
        let _ = StickyRepository.sharedInstance.saveSticky(sticky, newSticky: editSticky)
        return state
    }
}

struct BackHomeAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.home
        return state
    }
}

struct ListStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let page: PageEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.listSticky(page: page)
        return state
    }
}

struct ListingStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let page: PageEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.listingSticky(page: page)
        return state
    }
}


struct JumpStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.jumpSticky(sticky: sticky)
        return state
    }
}

struct ShowingPageAction: Delta.ActionType {
    typealias StateValueType = AppState
    let page: PageEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.page(page: page)
        return state
    }
}

struct SelectStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.selectSticky(sticky: sticky)
        return state
    }
}
