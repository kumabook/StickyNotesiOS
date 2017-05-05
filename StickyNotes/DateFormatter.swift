//
//  DateFormatter.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/14/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation

class DateFormatter {
    private static var __once: () = {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let posix = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = posix
        }()
    fileprivate static var dateFormatter = Foundation.DateFormatter()
    fileprivate static var onceToken : Int = 0
    static var shared: Foundation.DateFormatter {
        _ = DateFormatter.__once
        return dateFormatter
    }
}
