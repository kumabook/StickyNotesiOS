//
//  MessageView.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/07.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MessageView: UIView {
    var messageLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.themeColor
        messageLabel = UILabel()
        messageLabel.textColor = UIColor.white
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self).offset(-30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
