//
//  PageStickyTableViewCell.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/13/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class PageStickyTableViewCell: UITableViewCell {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: PageStickyTableViewController?
    var sticky: StickyEntity?
    var tagLabels: [UILabel] = []
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func editButtonTapped(sender: AnyObject) {
        guard let sticky = sticky else { return }
        delegate?.editButtonTapped(sticky)
    }

    func updateView(sticky: StickyEntity) {
        self.sticky = sticky
        separatorInset = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero

        contentTextView.text = sticky.content.characters.count > 0 ? sticky.content : "No content"
        contentTextView.textContainerInset = UIEdgeInsetsZero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.userInteractionEnabled = false

        locationLabel.text = "position: (\(sticky.left),\(sticky.top))"
        locationLabel.textColor = UIColor.ThemeColor()

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
