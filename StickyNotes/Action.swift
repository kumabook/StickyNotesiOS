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

struct CreateUserAction: Delta.ActionType {
    typealias StateValueType = AppState
    let email: String
    let password: String
    let passwordConfirmation: String

    func reduce(state: AppState) -> AppState {
        let request = CreateUserRequest(email: email, password: password, passwordConfirmation: passwordConfirmation)
        state.accountState.value = .creating
        Session.send(request) { result in
            switch result {
            case .success(_):
                Store.shared.dispatch(CreatedUserAction())
                Store.shared.dispatch(LoginAction(email: self.email, password: self.password))
            case .failure(let error):
                Store.shared.dispatch(FailToCreateUserAction(error: error))
            }
        }
        return state
    }
}

struct CreatedUserAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        state.accountState.value = .created
        return state
    }
}

struct FailToCreateUserAction: Delta.ActionType {
    typealias StateValueType = AppState
    let error: SessionTaskError
    func reduce(state: AppState) -> AppState {
        state.accountState.value = .failToCreate(error)
        return state
    }
}

struct LoginAction: Delta.ActionType {
    typealias StateValueType = AppState
    let email: String
    let password: String
    
    func reduce(state: AppState) -> AppState {
        let request = AccessTokenRequest(email: email, password: password)
        state.accountState.value = .loggingIn
        Session.send(request) { result in
            switch result {
            case .success(let accessToken):
                APIClient.shared.accessToken = accessToken
                Store.shared.dispatch(LoggedInAction(accessToken: accessToken))
                Store.shared.dispatch(FetchStickiesAction())
            case .failure(let error):
                Store.shared.dispatch(FailToLoginAction(error: error))
            }
        }
        return state
    }
}

struct LoggedInAction: Delta.ActionType {
    typealias StateValueType = AppState
    let accessToken: AccessToken
    func reduce(state: AppState) -> AppState {
        state.accountState.value = .login(accessToken)
        return state
    }
}

struct FailToLoginAction: Delta.ActionType {
    typealias StateValueType = AppState
    let error: SessionTaskError
    func reduce(state: AppState) -> AppState {
        state.accountState.value = .failToLogin(error)
        return state
    }
}

struct LogoutAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        APIClient.shared.accessToken = nil
        APIClient.shared.lastSyncedAt = nil
        StickyRepository.shared.clear()
        state.accountState.value = .logout
        return state
    }
}

struct FetchStickiesAction: Delta.ActionType {
    typealias StateValueType = AppState
    func reduce(state: AppState) -> AppState {
        state.stickiesRepository.updateStickies()
            .flatMap(FlattenStrategy.concat) {
                return state.stickiesRepository.fetchStickies()
            }.flatMap(FlattenStrategy.concat) {
                return state.stickiesRepository.fetchPages()
            }.startWithResult { result in
                if let _ = result.value {
                    Store.shared.dispatch(FetchedStickiesAction(isSuccess: true))
                } else {
                    Store.shared.dispatch(FetchedStickiesAction(isSuccess: false))
                }
        }
        return state
    }
}

struct FetchedStickiesAction: Delta.ActionType {
    typealias StateValueType = AppState
    var isSuccess: Bool
    func reduce(state: AppState) -> AppState {
        APIClient.shared.lastSyncedAt = Date()
        return state
    }
}

struct CreateStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        let _ = StickyRepository.shared.createSticky(sticky)
        return state
    }
}

struct DeleteStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        let _ = StickyRepository.shared.removeSticky(sticky)
        return state
    }
}

struct EditStickyAction: Delta.ActionType {
    typealias StateValueType = AppState
    let sticky: StickyEntity
    let editSticky: StickyEntity
    func reduce(state: AppState) -> AppState {
        state.mode.value = Mode.listingSticky(page: sticky.page!)
        let _ = StickyRepository.shared.saveSticky(sticky, newSticky: editSticky)
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
