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
    let accessToken: MutableProperty<AccessToken?>
    let stickiesRepository: StickyRepository
    let mode: MutableProperty<Mode>
}

struct Store: StoreType {
    var state: ObservableProperty<AppState>
    static var sharedInstance: Store = Store(state:
        ObservableProperty(AppState(accessToken: MutableProperty(APIClient.sharedInstance.accessToken),
                             stickiesRepository: StickyRepository(),
                                           mode: MutableProperty(.Home)))
    )
}

enum Mode {
    case Home
    case Page(page: PageEntity)
    case ListSticky(page: PageEntity)
    case ListingSticky(page: PageEntity)
    case SelectSticky(sticky: StickyEntity)
    case JumpSticky(sticky: StickyEntity)
}
