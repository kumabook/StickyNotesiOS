//
//  StickyTableViewCell.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/8/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class StickyTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var tagLabels: [UILabel] = []
    var colorEdgeView: UIView!
    var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        colorEdgeView = UIView()
        addSubview(colorEdgeView)
        separator = UIView()
        addSubview(separator)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateView(sticky: StickyEntity) {
        separatorInset = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero

        UITableView.appearance().cellLayoutMarginsFollowReadableWidth = false
        UITableView.appearance().layoutMargins = UIEdgeInsetsZero
        UITableViewCell.appearance().layoutMargins = UIEdgeInsetsZero
        UITableViewCell.appearance().preservesSuperviewLayoutMargins = false

        UITableView.appearance().separatorStyle = .SingleLine
        UITableView.appearance().separatorInset = UIEdgeInsetsZero
        UITableViewCell.appearance().separatorInset = UIEdgeInsetsZero

        contentTextView.text = sticky.content
        contentTextView.textContainerInset = UIEdgeInsetsZero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.userInteractionEnabled = false

        colorEdgeView.backgroundColor = sticky.backgroundColor
        colorEdgeView.frame = CGRect(x: 0, y: 0, width: 3, height: frame.height)

        separator.backgroundColor = UIColor.lightGrayColor()
        separator.frame = CGRect(x: 0, y: frame.height - 2, width: frame.width, height: 1)

        if sticky.content.characters.count == 0 {
            contentTextView.text = "No memo"
        }
        if let page = sticky.page {
            pageLabel.text = page.title
        } else {
            pageLabel.text = ""
        }
        dateLabel.text = sticky.updatedAt.passedTime
        dateLabel.textColor = UIColor.ThemeColor()

        tagLabels.forEach { $0.removeFromSuperview() }
        tagLabels.removeAll()
        let margins = layoutMarginsGuide
        let _ = sticky.tags.reduce((anchor: layoutMarginsGuide.leadingAnchor, margin: 14.0 as CGFloat)) { (prev, tag) in
            let label = TagLabel()
            label.text = tag.name
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            self.tagLabels.append(label)
            label.leadingAnchor.constraintEqualToAnchor(prev.anchor, constant: prev.margin).active = true
            label.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor).active = true
            return (anchor: label.trailingAnchor, margin: 8.0)
        }
    }
}

class TagLabel: UILabel {

    let padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.boldSystemFontOfSize(14.0)
        layer.cornerRadius = 8
        textColor = UIColor.whiteColor()
        backgroundColor = UIColor.ThemeLightColor()
        clipsToBounds = true
        numberOfLines = 1
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawTextInRect(rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawTextInRect(newRect)
    }

    override func intrinsicContentSize() -> CGSize {
        var intrinsicContentSize = super.intrinsicContentSize()
        intrinsicContentSize.height += padding.top + padding.bottom
        intrinsicContentSize.width += padding.left + padding.right
        return intrinsicContentSize
    }
}