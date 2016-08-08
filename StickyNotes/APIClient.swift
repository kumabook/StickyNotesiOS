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

class APIClient {
    let client_id = "..."
    let client_secret = "..."
    let baseUrl = "https://stickynotes-backend.herokuapp.com"
    var accessToken: AccessToken?
    static var sharedInstance: APIClient = APIClient()
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    var _accessToken: AccessToken?
    var accessToken: AccessToken? {
        get {
            if let token = _accessToken { return token }
            if let decoded = APIClient.userDefaults.objectForKey("access_token") as? [String: AnyObject] {
                return AccessToken(decoded: decoded)
            }
            return nil
        }
        set(token) {
            if let token = token {
                APIClient.userDefaults.setObject(token.encode(), forKey: "access_token")
            } else {
                APIClient.userDefaults.removeObjectForKey("access_token")
            }
            _accessToken = token
        }
    }
}

protocol StickyNoteRequestType: RequestType {
}

extension StickyNoteRequestType {
    var baseURL: NSURL {
        return NSURL(string: APIClient.sharedInstance.baseUrl)!
    }
}

extension StickyNoteRequestType where Response: Decodable {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
    var headerFields: [String : String] {
        if let token = APIClient.sharedInstance.accessToken {
            return ["Authorization": "Bearer \(token.accessToken)"]
        } else {
            return [:]
        }
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
                "client_id": APIClient.sharedInstance.client_id,
                "client_secret": APIClient.sharedInstance.client_secret,
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

    init(accessToken: String, createdAt: Int64, tokenType: String) {
        self.accessToken = accessToken
        self.createdAt = createdAt
        self.tokenType = tokenType
    }

    init?(decoded: [String:AnyObject]) {
        guard let accessToken = decoded["accessToken"] as? String,
              let createdAt = decoded["createdAt"] as? NSNumber,
              let tokenType = decoded["tokenType"] as? String
            else { return nil }
        self.init(accessToken: accessToken, createdAt: createdAt.longLongValue, tokenType: tokenType)
    }

    func encode() -> [String:AnyObject] {
        return ["accessToken": accessToken,
                "createdAt": NSNumber(longLong: createdAt),
                "tokenType": tokenType]
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
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return StickiesResponse(value: try decodeArray(object))
    }
}

struct StickiesResponse: Decodable {
    var value: [Sticky]
    static func decode(e: Extractor) throws -> StickiesResponse {
        return StickiesResponse(value: try e.array(KeyPath.empty))
    }
}
