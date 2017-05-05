//
//  AppState.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Delta
import ReactiveSwift
import APIKit

extension MutableProperty: ObservablePropertyType {
    public typealias ValueType = Value
}

struct AppState {
    let accountState: MutableProperty<AccountState>
    let stickiesRepository: StickyRepository
    let mode: MutableProperty<Mode>
}

struct Store: StoreType {
    var state: ObservableProperty<AppState>
    static var shared: Store = Store(state:
        ObservableProperty(AppState(accountState: MutableProperty(AccountState.initial()),
                              stickiesRepository: StickyRepository(),
                                            mode: MutableProperty(.home)))
    )
}

enum Mode {
    case home
    case page(page: PageEntity)
    case listSticky(page: PageEntity)
    case listingSticky(page: PageEntity)
    case selectSticky(sticky: StickyEntity)
    case jumpSticky(sticky: StickyEntity)
}

enum AccountState {
    case logout
    case loggingIn
    case login(AccessToken)
    case failToLogin(SessionTaskError)
    case loggingOut
    static func initial() -> AccountState {
        if let token = APIClient.shared.accessToken {
            return .login(token)
        } else {
            return .logout
        }
    }
}
