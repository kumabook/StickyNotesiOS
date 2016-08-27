//
//  Action.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Delta
import ReactiveCocoa
import APIKit

struct LoginAction: Delta.ActionType {
    let email: String
    let password: String
    
    func reduce(state: AppState) -> AppState {
        let request = AccessTokenRequest(email: email, password: password)
        Session.sendRequest(request) { result in
            switch result {
            case .Success(let accessToken):
                APIClient.sharedInstance.accessToken = accessToken
                Store.sharedInstance.dispatch(LoggedInAction(accessToken: accessToken))
                Store.sharedInstance.dispatch(FetchStickiesAction())
            case .Failure(let error):
                print("error: \(error)")
            }
        }
        return state
    }
}

struct LoggedInAction: Delta.ActionType {
    let accessToken: AccessToken
    func reduce(state: AppState) -> AppState {
        state.accessToken.value = accessToken
        return state
    }
}

struct LogoutAction: Delta.ActionType {
    func reduce(state: AppState) -> AppState {
        APIClient.sharedInstance.accessToken = nil
        APIClient.sharedInstance.lastSyncedAt = NSDate(timeIntervalSince1970: 0)
        StickyRepository.sharedInstance.clear()
        state.accessToken.value = nil
        return state
    }
}

struct FetchStickiesAction: Delta.ActionType {
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
    func reduce(state: AppState) -> AppState {
        return state
    }
}

struct DeleteStickyAction: Delta.ActionType {
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        StickyRepository.sharedInstance.removeSticky(sticky)
        return state
    }
}

struct EditStickyAction: Delta.ActionType {
    let sticky: StickyEntity
    let editSticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.ListingSticky(page: sticky.page!)
        StickyRepository.sharedInstance.saveSticky(sticky, newSticky: editSticky)
        return state
    }
}

struct BackHomeAction: Delta.ActionType {
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.Home
        return state
    }
}

struct ListStickyAction: Delta.ActionType {
    let page: PageEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.ListSticky(page: page)
        return state
    }
}

struct ListingStickyAction: Delta.ActionType {
    let page: PageEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.ListingSticky(page: page)
        return state
    }
}


struct JumpStickyAction: Delta.ActionType {
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.JumpSticky(sticky: sticky)
        return state
    }
}

struct ShowingPageAction: Delta.ActionType {
    let page: PageEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.Page(page: page)
        return state
    }
}

struct SelectStickyAction: Delta.ActionType {
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.SelectSticky(sticky: sticky)
        return state
    }
}