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
    func longTapped(_ coordinate: CGPoint) {}
}
func ==(lhs: WindowObserver, rhs: WindowObserver) -> Bool {
    return lhs.isEqual(rhs)
}
class ObservableWindow: UIWindow {
    fileprivate let longTapDuration: CGFloat = 0.4
    fileprivate var longPressTimer: Timer?
    fileprivate var isKeepLongpPress: Bool = false
    var observers: [WindowObserver] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addObserver(_ observer: WindowObserver) {
        observers.append(observer)
    }
    func removeObserver(_ observer: WindowObserver) {
        if let index = observers.index(of: observer) {
            observers.remove(at: index)
        }
    }
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if let touches = event.touches(for: self), touches.count > 0 {
            let touch = touches.first!
            switch touch.phase {
            case UITouchPhase.began:
                longPressTimer?.invalidate()
                let coordinate = touch.location(in: self)
                let coordinateValue = NSValue(cgPoint: coordinate)
                longPressTimer = Timer.scheduledTimer(timeInterval: TimeInterval(longTapDuration),
                                                                        target: self,
                                                                        selector: #selector(ObservableWindow.longPressTimerHandle(_:)),
                                                                        userInfo: coordinateValue,
                                                                        repeats: false)
            case .moved:
                longPressTimer?.invalidate()
                longPressTimer = nil;
            case .ended:
                longPressTimer?.invalidate()
                longPressTimer = nil;
            case .cancelled:
                longPressTimer?.invalidate()
                longPressTimer = nil;
            case .stationary:
                break
            }
        } else {
            longPressTimer?.invalidate()
            longPressTimer = nil;
        }
    }
    func longPressTimerHandle(_ timer: Timer) {
        if let coordinateValue = timer.userInfo as? NSValue {
            let coordinate = coordinateValue.cgPointValue
            for observer in observers {
                observer.longTapped(coordinate)
            }
        }
    }
}
