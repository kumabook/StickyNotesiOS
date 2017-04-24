//
//  PageTableViewCell.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/13/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stickiesNumLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
