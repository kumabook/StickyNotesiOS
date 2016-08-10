//
//  ObservableWindow.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/8/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import UIKit

class WindowObserver: NSObject {
    func longTapped(coordinate: CGPoint) {}
}
func ==(lhs: WindowObserver, rhs: WindowObserver) -> Bool {
    return lhs.isEqual(rhs)
}
class ObservableWindow: UIWindow {
    private let longTapDuration: CGFloat = 0.4
    private var longPressTimer: NSTimer?
    private var isKeepLongpPress: Bool = false
    var observers: [WindowObserver] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addObserver(observer: WindowObserver) {
        observers.append(observer)
    }
    func removeObserver(observer: WindowObserver) {
        if let index = observers.indexOf(observer) {
            observers.removeAtIndex(index)
        }
    }
    override func sendEvent(event: UIEvent) {
        super.sendEvent(event)
        if let touches = event.touchesForWindow(self) where touches.count > 0 {
            let touch = touches.first!
            switch touch.phase {
            case UITouchPhase.Began:
                longPressTimer?.invalidate()
                let coordinate = touch.locationInView(self)
                let coordinateValue = NSValue(CGPoint: coordinate)
                longPressTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(longTapDuration),
                                                                        target: self,
                                                                        selector: #selector(ObservableWindow.longPressTimerHandle(_:)),
                                                                        userInfo: coordinateValue,
                                                                        repeats: false)
            case .Moved:
                longPressTimer?.invalidate()
                longPressTimer = nil;
            case .Ended:
                longPressTimer?.invalidate()
                longPressTimer = nil;
            case .Cancelled:
                longPressTimer?.invalidate()
                longPressTimer = nil;
            case .Stationary:
                break
            }
        } else {
            longPressTimer?.invalidate()
            longPressTimer = nil;
        }
    }
    func longPressTimerHandle(timer: NSTimer) {
        if let coordinateValue = timer.userInfo as? NSValue {
            let coordinate = coordinateValue.CGPointValue()
            for observer in observers {
                observer.longTapped(coordinate)
            }
        }
    }
}