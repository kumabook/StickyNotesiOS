//
//  UINavigationController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/05.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}
