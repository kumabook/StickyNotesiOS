//
//  AppState.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Delta
import ReactiveCocoa

extension MutableProperty: ObservablePropertyType {
    public typealias ValueType = Value
}

struct AppState {
    var accessToken: AccessToken?
    let stickiesRepository: StickyRepository
}

struct Store: StoreType {
    var state: ObservableProperty<AppState>
    static var sharedInstance: Store = Store(state:
        ObservableProperty(AppState(accessToken: APIClient.sharedInstance.accessToken,
                             stickiesRepository: StickyRepository()))
    )
}

