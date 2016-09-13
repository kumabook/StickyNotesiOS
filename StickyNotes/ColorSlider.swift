//
//  ColorSlider.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 9/13/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class ColorSlider: UISlider {
    let thumbWidth = 40 as CGFloat
    let thumbHeight = 40 as CGFloat
    override func thumbRectForBounds(bounds: CGRect, trackRect: CGRect, value: Float) -> CGRect {
        let x = trackRect.width * CGFloat(value / maximumValue) - thumbWidth / 2.0
        return CGRectMake(x, 0, thumbWidth, thumbHeight)
    }
}