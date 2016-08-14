//
//  DateFormatter.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/14/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation

class DateFormatter {
    private static var dateFormatter = NSDateFormatter()
    private static var onceToken : dispatch_once_t = 0
    static var sharedInstance: NSDateFormatter {
        dispatch_once(&onceToken) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let posix = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.locale = posix
        }
        return dateFormatter
    }
}