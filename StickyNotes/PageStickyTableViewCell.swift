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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func editButtonTapped(_ sender: AnyObject) {
        guard let sticky = sticky else { return }
        delegate?.editButtonTapped(sticky)
    }

    func updateView(_ sticky: StickyEntity) {
        self.sticky = sticky
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero

        contentTextView.text = sticky.content.characters.count > 0 ? sticky.content : "No content".localize()
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.isUserInteractionEnabled = false

        locationLabel.text = "position: (\(sticky.left),\(sticky.top))"
        locationLabel.textColor = UIColor.themeColor

        dateLabel.text = sticky.updatedAt.passedTime
        dateLabel.textColor = UIColor.themeColor

        tagLabels.forEach { $0.removeFromSuperview() }
        tagLabels.removeAll()
        let margins = layoutMarginsGuide
        let _ = sticky.tags.reduce((anchor: layoutMarginsGuide.leadingAnchor, margin: 14.0 as CGFloat)) { (prev, tag) in
            let label = TagLabel()
            label.text = tag.name
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            self.tagLabels.append(label)
            label.leadingAnchor.constraint(equalTo: prev.anchor, constant: prev.margin).isActive = true
            label.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
            return (anchor: label.trailingAnchor, margin: 8.0)
        }
        editButton.titleLabel?.text = "Edit".localize()
    }
}
