//
//  Page.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import Himotoki

struct Page: Decodable {
    var url: String
    var title: String
    static func decode(_ e: Extractor) throws -> Page {
        return try Page(url: e <| "url", title: e <| "title")
    }
}
