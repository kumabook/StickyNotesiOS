//
//  TagStickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class TagStickyTableViewController: StickyTableViewController {
    var tag: TagEntity!
    init(tag: TagEntity) {
        self.tag = tag
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Stickies"

        let nib = UINib(nibName: "StickyTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)

        self.stickies = tag.stickies.filter(NSPredicate(value: true))
    }
}
