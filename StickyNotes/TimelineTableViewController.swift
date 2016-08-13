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

        self.reloadData()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(TimelineTableViewController.reload), forControlEvents: UIControlEvents.ValueChanged)
    }

    func reload() {
        reloadData()
        Store.sharedInstance.dispatch(FetchStickiesAction())
    }

    func reloadData() {
        self.stickies = Store.sharedInstance.state.value.stickiesRepository.items
        self.tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Store.sharedInstance.state.value.stickiesRepository.state.signal.observeNext() { [weak self] state in
            switch state {
            case .Normal:
                self?.refreshControl?.endRefreshing()
                self?.reloadData()
            case .Fetching:
                self?.refreshControl?.beginRefreshing()
            }
        }
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
    }
}
