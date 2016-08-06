//
//  APIClient.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

let client_id = "..."
let client_secret = "..."
let baseUrl = "https://stickynotes-backend.herokuapp.com"

protocol StickyNoteRequestType: RequestType {
}

extension StickyNoteRequestType where Response: Decodable {
    var baseURL: NSURL {
        return NSURL(string: baseUrl)!
    }
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}

struct AccessTokenRequest: StickyNoteRequestType {
    typealias Response = AccessToken
    var email: String
    var password: String
    var path: String { return "/oauth/token.json" }
    var method: HTTPMethod { return .POST }
    var parameters: AnyObject? {
        return ["grant_type": "password",
                "client_id": client_id,
                "client_secret": client_secret,
                "username": email,
                "password": password]
    }
}

struct AccessToken: Decodable {
    var accessToken: String
    var createdAt: Int64
    var tokenType: String
    static func decode(e: Extractor) throws -> AccessToken {
        return try AccessToken(
            accessToken: e.value("access_token"),
            createdAt: e.value("created_at"),
            tokenType: e.value("token_type"))
    }
}

