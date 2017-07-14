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
    var clientId     = "xxxxx"
    var clientSecret = "xxxxx"
    var baseUrl      = "https://stickynotes-backend.herokuapp.com"
    static var shared: APIClient = APIClient()
    
    var passwordResetURL: URL? {
        return URL(string: "\(baseUrl)/password_resets/new")
    }

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
            APIClient.userDefaults.synchronize()
        }
    }
    var lastSyncedAt: Date? {
        get {
            if isLoggedIn, let date = APIClient.userDefaults.object(forKey: "last_synced_at") as? Date {
                return date
            }
            return nil
        }
        set(date) {
            if let date = date {
                APIClient.userDefaults.set(date, forKey: "last_synced_at")
            } else {
                APIClient.userDefaults.removeObject(forKey: "last_synced_at")
            }
            APIClient.userDefaults.synchronize()
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
                "client_id": APIClient.shared.clientId,
                "client_secret": APIClient.shared.clientSecret,
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
    var method: HTTPMethod { return .post }
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

struct PagesRequest: StickyNoteRequest {
    typealias Response = PagesResponse
    var newerThan: Date
    var path: String { return "/api/v1/pages.json" }
    var method: HTTPMethod { return .get }
    var parameters: Any? {
        return ["newer_than": DateFormatter.shared.string(from: newerThan)]
    }
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return PagesResponse(value: try decodeArray(object))
    }
}

struct PagesResponse: Decodable {
    var value: [Page]
    static func decode(_ e: Extractor) throws -> PagesResponse {
        return PagesResponse(value: try e.array(KeyPath.empty))
    }
}

struct CreateUserRequest: StickyNoteRequest {
    var path: String { return "/api/v1/users.json" }
    typealias Response = CreateUserResponse
    var email: String
    var password: String
    var passwordConfirmation: String
    var method: HTTPMethod { return .post }
    var parameters: Any? {
        return ["email": email, "password": password, "password_confirmation": passwordConfirmation]
    }
}

struct CreateUserResponse: Decodable {
    var id:    Int
    var email: String
    static func decode(_ e: Extractor) throws -> CreateUserResponse {
        return try CreateUserResponse(id: e.value("id"), email: e.value("email"))
    }
}
