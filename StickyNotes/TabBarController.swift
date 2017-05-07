//
//  TabBarController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/06.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    var messageView: MessageView!
    var messageViewHeight: CGFloat = 50.0
    var animationDuration: TimeInterval = 0.3

    override func viewDidLoad() {
        super.viewDidLoad()
        let f  = view.frame
        let bh = tabBar.frame.height
        let mh = messageViewHeight
        messageView = MessageView(frame: CGRect(x: 0, y: f.height - bh - mh, width: f.width, height: mh))
        messageView.backgroundColor = UIColor.themeColor
        view.addSubview(messageView)
        Store.shared.state.value.stickiesRepository.state.signal.observe { [weak self] event in
            guard let strongSelf = self else { return }
            guard let state = event.value else { return }
            switch state {
            case .normal:
                strongSelf.hideMessage(true)
            case .fetching:
                strongSelf.showMessage(true, message: "Fething latest data...")
            case .updating:
                strongSelf.showMessage(true, message: "Sending update data...")
            }
        }
        hideMessage(false)
    }

    public func showMessage(_ animated: Bool, message: String) {
        messageView.messageLabel.text = message
        let f = messageView.frame
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            self.messageView.frame = CGRect(x: 0, y: f.minY, width: f.width, height: f.height)
        }
    }

    public func hideMessage(_ animated: Bool) {
        let f = messageView.frame
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            self.messageView.frame = CGRect(x: -f.width, y: f.minY, width: f.width, height: f.height)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
