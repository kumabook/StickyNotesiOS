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

extension StickyNoteRequestType {
    var baseURL: NSURL {
        return NSURL(string: baseUrl)!
    }
}

extension StickyNoteRequestType where Response: Decodable {
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

struct StickiesRequest: StickyNoteRequestType {
    typealias Response = StickiesResponse
    var newerThan: NSDate
    var path: String { return "/api/v1/stickies.json" }
    var method: HTTPMethod { return .GET }
    var parameters: AnyObject? {
        let dateFormatter = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return ["newer_than": dateFormatter.stringFromDate(newerThan)]
    }
}

struct StickiesResponse: Decodable {
    var value: [Sticky]
    static func decode(e: Extractor) throws -> StickiesResponse {
        return StickiesResponse(value: try e.array(KeyPath.empty))
    }
}

struct Sticky: Decodable {
    var id: String
    var uuid: String
    var page_id: Int
    var left: Int
    var top: Int
    var width: Int
    var height: Int
    var content: String
    var color: String
    var state: Int
    var createdAt: NSDate
    var updatedAt: NSDate
    var userId: Int

    static func decode(e: Extractor) throws -> Sticky {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let posix = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.locale = posix
        return try Sticky(
            id: e <| "id",
            uuid: e <| "uuid",
            page_id: e <| "page_id",
            left: e <| "left",
            top:  e <| "top",
            width: e <| "width",
            height: e <| "height",
            content: e <| "content",
            color: e <| "color",
            state: e <| "state",
            createdAt: formatter.dateFromString(e <| "created_at")!,
            updatedAt: formatter.dateFromString(e <| "updated_at")!,
            userId: e <| "user_id")
    }
}