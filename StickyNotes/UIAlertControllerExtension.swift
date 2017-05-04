//
//  UIAlertControllerExtension.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/04.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    class func show(_ vc: UIViewController, title: String, message: String, handler: @escaping (UIAlertAction!) -> Void) -> UIAlertController {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK".localize(), style: UIAlertActionStyle.default, handler: handler)
        ac.addAction(okAction)
        vc.present(ac, animated: true, completion: nil)
        return ac
    }
    class func showPurchaseAlert(_ vc: UIViewController) -> UIAlertController {
        let title   = "プレミアムサービス"
        let message = "この機能を使うためには、プレミアムサービスのを購入が必要です。"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Purchase".localize(), style: .default) { action in
            AppDelegate.shared.paymentManager?.viewController = vc
            AppDelegate.shared.paymentManager?.purchaseMultiDeviceSync()
        })
        ac.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel) {action in })
        vc.present(ac, animated: true, completion: {})
        return ac
    }
}
