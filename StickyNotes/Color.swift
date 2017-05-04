//
//  Color.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/13/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(rgb: Int) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >>  8) / 255.0
        let b = CGFloat( rgb & 0x0000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    static var themeColor: UIColor {
        return UIColor(rgb: 0x3cb7e8)
    }

    static var themeLightColor: UIColor {
        return UIColor(rgb: 0x87CEEB)
    }
}

struct Color {
    var id:         String
    var background: Int
    var font:       Int
    
    var backgroundColor: UIColor {
        return UIColor(rgb: background)
    }

    var fontColor: UIColor {
        return UIColor(rgb: font)
    }
    
    static var values: [Color] = [Color(id:    "navy", background: 0x001f3f, font: 0xffffff),
                                  Color(id:    "blue", background: 0x0074d9, font: 0xffffff),
                                  Color(id:    "aqua", background: 0x7fdbff, font: 0x000000),
                                  Color(id:    "teal", background: 0x39cccc, font: 0x000000),
                                  Color(id:   "olive", background: 0x3d9970, font: 0xffffff),
                                  Color(id:   "green", background: 0x2ecc40, font: 0xffffff),
                                  Color(id:    "lime", background: 0x01ff70, font: 0x000000),
                                  Color(id:  "yellow", background: 0xf1c40f, font: 0x000000),
                                  Color(id:  "orange", background: 0xff851b, font: 0x000000),
                                  Color(id:     "red", background: 0xff4136, font: 0x000000),
                                  Color(id:  "maroon", background: 0x85144b, font: 0xffffff),
                                  Color(id: "fuchsia", background: 0xf012be, font: 0xffffff),
                                  Color(id:  "purple", background: 0xb10dc9, font: 0xffffff),
                                  Color(id:   "black", background: 0x111111, font: 0xffffff),
                                  Color(id:    "gray", background: 0xaaaaaa, font: 0x000000),
                                  Color(id:  "silver", background: 0xdddddd, font: 0x000000)]
    static func get(_ id: String) -> Color? {
        return values.filter { $0.id ==  id }.first
    }
}
