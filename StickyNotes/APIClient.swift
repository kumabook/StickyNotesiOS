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
    let client_id = "7ec2c1d36bfb9335d5779362efe27acf1108430969c30edbf60e27f6e1bcbfbb"
    let client_secret = "8d5f20e78956b51e1e4a6213a7d4d8e0e7c1eefce7c0a9ac500e2ec93f6b439b"
    let baseUrl = "https://stickynotes-backend.herokuapp.com"
    static var shared: APIClient = APIClient()

    fileprivate static let userDefaults: UserDefaults! = UserDefaults(suiteName: "group.io.kumabook.StickyNotes")
    var isLoggedIn: Bool { return accessToken != nil }
    var accessToken: AccessToken? {
        get {
            if let decoded = APIClient.userDefaults.object(forKey: "access_token") as? [String: AnyObject] {
                return AccessToken(decoded: decoded)
            }
            return nil
        }
        set(token) {
            if let token = token {
                APIClient.userDefaults.set(token.encode(), forKey: "access_token")
            } else {
                APIClient.userDefaults.set(nil, forKey: "access_token")
            }
        }
    }
    var lastSyncedAt: Date? {
        get {
            if let date = APIClient.userDefaults.object(forKey: "last_synced_at") as? Date {
                return date
            }
            return nil
        }
        set(date) {
            APIClient.userDefaults.set(date, forKey: "last_synced_at")
        }
    }
}

protocol StickyNoteRequest: Request {
}

extension StickyNoteRequest {
    var baseURL: URL {
        return URL(string: APIClient.shared.baseUrl)!
    }
}

extension StickyNoteRequest where Response: Decodable {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
    var headerFields: [String : String] {
        if let token = APIClient.shared.accessToken {
            return ["Authorization": "Bearer \(token.accessToken)"]
        } else {
            return [:]
        }
    }
}


struct AccessTokenRequest: StickyNoteRequest {
    typealias Response = AccessToken
    var email: String
    var password: String
    var path: String { return "/oauth/token.json" }
    var method: HTTPMethod { return .post }
    var parameters: Any? {
        return ["grant_type": "password",
                "client_id": APIClient.shared.client_id,
                "client_secret": APIClient.shared.client_secret,
                "username": email,
                "password": password]
    }
}

struct AccessToken: Decodable {
    var accessToken: String
    var createdAt: Int64
    var tokenType: String
    static func decode(_ e: Extractor) throws -> AccessToken {
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
        self.init(accessToken: accessToken, createdAt: createdAt.int64Value, tokenType: tokenType)
    }

    func encode() -> [String:AnyObject] {
        return ["accessToken": accessToken as AnyObject,
                "createdAt": NSNumber(value: createdAt as Int64),
                "tokenType": tokenType as AnyObject]
    }
}

struct StickiesRequest: StickyNoteRequest {
    typealias Response = StickiesResponse
    var newerThan: Date
    var path: String { return "/api/v1/stickies.json" }
    var method: HTTPMethod { return .get }
    var parameters: Any? {
        return ["newer_than": DateFormatter.shared.string(from: newerThan)]
    }
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return StickiesResponse(value: try decodeArray(object))
    }
}

struct StickiesResponse: Decodable {
    var value: [Sticky]
    static func decode(_ e: Extractor) throws -> StickiesResponse {
        return StickiesResponse(value: try e.array(KeyPath.empty))
    }
}

struct UpdateStickiesRequest: StickyNoteRequest {
    typealias Response = UpdateStickiesResponse
    var stickies: [StickyEntity]

    var path: String { return "/api/v1/stickies.json" }
    var method: HTTPMethod { return .get }
    var parameters: Any? {
        return ["stickies": stickies.map { $0.toParameter() }]
    }
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return UpdateStickiesResponse()
    }
}

struct UpdateStickiesResponse: Decodable {
    static func decode(_ e: Extractor) throws -> UpdateStickiesResponse {
        return UpdateStickiesResponse()
    }
}
