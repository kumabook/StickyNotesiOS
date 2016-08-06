//
//  Tag.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import Himotoki

struct Tag: Decodable {
    var name: String
    static func decode(e: Extractor) throws -> Tag {
        return try Tag(name: e <| "name")
    }
}