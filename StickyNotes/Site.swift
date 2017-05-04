//
//  Site.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/04/29.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation

struct Site {
    var title:    String
    var url:      URL
    var imageURL: URL?
}

extension Site {
    static let productSite     = "https://kumabook.github.io/stickynotes"
    static let googleThumbUrl  = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png"
    static let wikiThumbUrl    = "https://en.wikipedia.org/static/images/project-logos/enwiki-2x.png"
    static let youtubeThumbUrl = "https://www.youtube.com/yts/img/yt_1200-vfl4C3T0K.png"
    static let yahooThumbUrl   = "https://s1.yimg.com/rz/d/yahoo_en-US_f_p_bestfit_2x.png"
    static let appThumbUrl     = "http://kumabook.github.io/stickynotes/img/icon.png"
    static let defaultSites: [Site] = [
        Site(title: "Google"     , url: URL(string: "https://www.google.com/")!  , imageURL: URL(string: googleThumbUrl)!),
        Site(title: "Wikipedia"  , url: URL(string: "https://en.wikipedia.org/")!, imageURL: URL(string: wikiThumbUrl)!),
        Site(title: "YouTube"    , url: URL(string: "https://www.youtube.com/")! , imageURL: URL(string: youtubeThumbUrl)!),
        Site(title: "Yahoo!"     , url: URL(string: "https://www.yahoo.com/")!   , imageURL: URL(string: yahooThumbUrl)!),
        Site(title: "stickynotes", url: URL(string: productSite)!                , imageURL: URL(string: appThumbUrl)!),
    ]
}
