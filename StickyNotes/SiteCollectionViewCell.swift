//
//  SiteCollectionViewCell.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/04/28.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit

class SiteCollectionViewCell: UICollectionViewCell {
    var titleLabel: UILabel!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let length = frame.size.width - 48
        imageView = UIImageView(frame: CGRect(x: 24, y: 12, width: length, height: length))
        imageView.contentMode = .scaleAspectFit
        titleLabel = UILabel(frame:  CGRect(x: 0, y: imageView.frame.size.height + 12 , width: frame.size.width, height: frame.size.height / 3))
        titleLabel.textAlignment = NSTextAlignment.center
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
