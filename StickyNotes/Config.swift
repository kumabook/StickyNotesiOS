//
//  Config.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/07.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import Himotoki

struct Config: Decodable {
    var baseUrl:                    String
    var clientId:                   String
    var clientSecret:               String
    var admobApplicationID:         String
    var admobTableViewCellAdUnitID: String
    var admobBannerAdUnitID:        String
    var fabricApiKey:               String

    static private var defaultConfig: Config? = nil

    static public var `default`: Config? {
        if let config  = defaultConfig { return config }
        guard let filePath = Bundle.main.path(forResource: "config", ofType: "json") else { return nil }
        guard let data     = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return nil }
        guard let json     = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return nil }
        guard let config   = try? Config.decodeValue(json) else { return nil }
        defaultConfig = config
        return config
    }
    
    static func decode(_ e: Extractor) throws -> Config {
        return try Config(
            baseUrl:                    e <| "baseUrl",
            clientId:                   e <| "clientId",
            clientSecret:               e <| "clientSecret",
            admobApplicationID:         e <| "admobApplicationID",
            admobTableViewCellAdUnitID: e <| "abmobTableViewCellAdUnitID",
            admobBannerAdUnitID:        e <| "admobBannerAdUnitID",
            fabricApiKey:               e <| "fabricApiKey"
        )
    }
}


