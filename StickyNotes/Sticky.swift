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
    fileprivate static var onceToken : Int = 0
    enum State: Int {
        case normal = 0
        case deleted = 1
        case minimized = 2
        static func fromRawValue(_ rawValue: Int) -> State {
            if let s = State(rawValue: rawValue) {
                return s
            } else {
                return .normal
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
    var createdAt: Date
    var updatedAt: Date
    var userId: Int
    var page: Page
    var tags: [String]
    
    static func decode(_ e: Extractor) throws -> Sticky {
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
            createdAt: DateFormatter.shared.date(from: e <| "created_at")!,
            updatedAt: DateFormatter.shared.date(from: e <| "updated_at")!,
            userId: e <| "user_id",
            page: e <| "page",
            tags: e <|| "tags")
    }
}
