//
//  TimelineTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import Breit

class TimelineTableViewController: StickyTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Stickies"

        let nib = UINib(nibName: "StickyTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)

        self.stickies = StickyRepository.sharedInstance.items.map { $0 }
    }
}
