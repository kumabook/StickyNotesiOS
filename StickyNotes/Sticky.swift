//
//  Sticky.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import Himotoki
import RealmSwift

struct Sticky: Decodable {
    private static var onceToken : dispatch_once_t = 0
    enum State: Int {
        case Normal = 0
        case Deleted = 1
        case Minimized = 2
        static func fromRawValue(rawValue: Int) -> State {
            if let s = State(rawValue: rawValue) {
                return s
            } else {
                return .Normal
            }
        }
    }
    var id: Int
    var uuid: String
    var left: Int
    var top: Int
    var width: Int
    var height: Int
    var content: String
    var color: String
    var state: State
    var createdAt: NSDate
    var updatedAt: NSDate
    var userId: Int
    var page: Page
    var tags: [String]
    
    static func decode(e: Extractor) throws -> Sticky {
        return try Sticky(
            id: e <| "id",
            uuid: e <| "uuid",
            left: e <| "left",
            top:  e <| "top",
            width: e <| "width",
            height: e <| "height",
            content: e <| "content",
            color: e <| "color",
            state: State.fromRawValue(e <| "state"),
            createdAt: DateFormatter.sharedInstance.dateFromString(e <| "created_at")!,
            updatedAt: DateFormatter.sharedInstance.dateFromString(e <| "updated_at")!,
            userId: e <| "user_id",
            page: e <| "page",
            tags: e <|| "tags")
    }
}