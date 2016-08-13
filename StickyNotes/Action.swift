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
        return AppState(accessToken: accessToken, stickiesRepository: state.stickiesRepository)
    }
}

struct LogoutAction: Delta.ActionType {
    func reduce(state: AppState) -> AppState {
        APIClient.sharedInstance.accessToken = nil
        StickyRepository.sharedInstance.clear()
        return AppState(accessToken: nil, stickiesRepository: state.stickiesRepository)
    }
}

struct FetchStickiesAction: Delta.ActionType {
    func reduce(state: AppState) -> AppState {
        state.stickiesRepository.fetchStickies() { isSuccess in
            if isSuccess {
                Store.sharedInstance.dispatch(FetchedStickiesAction())
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